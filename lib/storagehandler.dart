import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';

class FileAccessWrapper{
  // This is a wrapper class for file operations -> designed for unit testing

  Future<bool> exists(File file) async => file.exists();
  Future<RandomAccessFile> open(File file) async => file.open();
  Future<FileSystemEntity> delete(File file) async => file.delete();
}

class PlatformWrapper{
  // This is a wrapper class for Platform specific queries -> neccessary for unit testing
  //
  // Its purpose is to provide a unit testable interface.

  bool isAndroid() => Platform.isAndroid;
  Future<bool> isGranted(Permission permission) async => await permission.isGranted;
  Future<PermissionStatus> request(Permission permission) async => await permission.request();
}



class StorageHandler {
  late final FileAccessWrapper _fileAccessWrapper;
  StorageHandler({fileAccessWrapper = FileAccessWrapper}){_fileAccessWrapper = fileAccessWrapper;}

  Future<Image> getImage(String filepath) async{
    File file= File(filepath);
    await _fileAccessWrapper.open(file);
    return Image.file(file);
  }

  Future<void> deleteFile(String filepath) async{
    File file= File(filepath);
    await _fileAccessWrapper.delete(file);
  }

  Future <bool> getPermission(Permission permission, PlatformWrapper wrapper) async {
    if(await wrapper.isGranted(permission)){
      return true;
    }
    else {
      final bool status = await wrapper.request(permission).isGranted;
      return status;
    }
  }
}