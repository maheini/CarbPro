import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:url_launcher/url_launcher.dart';

class FileAccessWrapper {
  // This is a wrapper class for file operations -> designed for unit testing

  // coverage:ignore-start
  Future<bool> exists(File file) async => file.exists();
  Future<bool> existsDir(Directory dir) async => dir.exists();
  Future<bool> writeFile(File file, String content) async {
    try {
      await file.writeAsString(content);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<String?> readFile(File file) async => file.readAsString();

  Future<RandomAccessFile> openFile(File file) async => file.open();
  Future<File> copyFile(File file, String newPath) async => file.copy(newPath);
  Future<FileSystemEntity> deleteFile(File file) async => file.delete();
  // coverage:ignore-end
}

class PlatformWrapper {
  // This is a wrapper class for Platform specific queries -> neccessary for unit testing
  //
  // Its purpose is to provide a unit testable interface.

  // coverage:ignore-start
  bool isAndroid() => Platform.isAndroid;
  Future<bool> isGranted(Permission permission) async =>
      await permission.isGranted;
  Future<PermissionStatus> request(Permission permission) async =>
      await permission.request();

  Future<bool> openUrl(String url, {bool external = false}) async {
    Uri uri = Uri.parse(url);
    return external
        ? await launchUrl(uri, mode: LaunchMode.externalApplication)
        : await launchUrl(uri);
  }

  Future<int?> getSdkVersion() async {
    var androidInfo = await DeviceInfoPlugin().androidInfo;
    return androidInfo.version.sdkInt;
  }
  // coverage:ignore-end
}

class StorageHandler {
  @visibleForTesting
  PlatformWrapper platformWrapper = PlatformWrapper();
  late final FileAccessWrapper _fileAccessWrapper;
  StorageHandler(this._fileAccessWrapper);

  Future<int?> getSdkVersion() async => platformWrapper.getSdkVersion();

  Future<Directory?> getExternalStorageDirectory() async {
    return await path_provider.getExternalStorageDirectory();
  }

  Future<Directory?> getTempStorageDirectory() async {
    return await path_provider.getTemporaryDirectory();
  }

  Future<bool> exists(File file) => file.exists();

  Future<Image> getImage(String filepath) async {
    File file = File(filepath);
    await _fileAccessWrapper.openFile(file);
    return Image.file(file);
  }

  Future<File> copyFile(String filepath, String newFilePath) async {
    File file = File(filepath);
    return await _fileAccessWrapper.copyFile(file, newFilePath);
  }

  Future<void> deleteFile(String filepath) async {
    File file = File(filepath);
    await _fileAccessWrapper.deleteFile(file);
  }

  Future<bool> getPermission(
      Permission permission, PlatformWrapper wrapper) async {
    if (await wrapper.isGranted(permission)) {
      return true;
    } else {
      final bool status = await wrapper.request(permission).isGranted;
      return status;
    }
  }

  Future<bool> exportItems(String json, String externalStorageDir,
      List<File> images, PlatformWrapper platformWrapper,
      {TarFileEncoder? encoder}) async {
    try {
      // Write json file
      File output = File(externalStorageDir + '/items.json');
      if (!await _fileAccessWrapper.writeFile(output, json)) {
        return false;
      }

      encoder ??= TarFileEncoder();
      Directory dir = Directory('storage/emulated/0/Download/');
      if (!await _fileAccessWrapper.existsDir(dir)) return false;

      encoder.create(('/storage/emulated/0/Download/carbpro_export.tar'));
      for (File image in images) {
        await encoder.addFile(image, image.path.split('/').last);
      }
      await encoder.addFile(output, output.path.split('/').last);
      await encoder.close();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<Directory?> import(Directory externalStorage, Directory temp,
      {FilePicker? filepicker}) async {
    filepicker ??= FilePicker.platform;

    await filepicker.clearTemporaryFiles();
    FilePickerResult? result = await filepicker
        .pickFiles(type: FileType.custom, allowedExtensions: ['tar']);

    if (result == null) return null;

    temp = Directory(temp.path + '/carbpro_import');
    await temp.exists()
        ? await temp.delete(recursive: true)
        : await temp.create();

    File file = File(result.files.single.path!);
    // Read the Tar file from disk.
    final bytes = file.readAsBytesSync();
    // Decode the Tar file
    final archive = TarDecoder().decodeBytes(bytes);
    // Extract the contents of the Tar archive to disk.
    for (final file in archive) {
      final outputStream = OutputFileStream('${temp.path}/${file.name}');
      // The writeContent method will decompress the file content directly to disk without
      // storing the decompressed data in memory.
      file.writeContent(outputStream);
      // Make sure to close the output stream so the File is closed.
      await outputStream.close();
    }
    return temp;
  }
}
