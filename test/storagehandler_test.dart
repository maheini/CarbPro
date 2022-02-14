import 'dart:io';
import 'package:carbpro/handler/storagehandler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'storagehandler_test.mocks.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

@GenerateMocks([FileAccessWrapper, PlatformWrapper])
void main() {
  group('Test File Access', () {
    // todo: add failing tests and implement exception handling

    // getImage
    test('Open Image: Should return a valid Image', () async {
      // Arrange
      File imageFile = File('assets/storagehandler_test_image.jpg');
      Future<RandomAccessFile> returnValue = imageFile.open();
      MockFileAccessWrapper mockFileAccessWrapper = MockFileAccessWrapper();
      when(mockFileAccessWrapper.openFile(any)).thenAnswer((invocation) {
        return returnValue;
      });
      StorageHandler handler = StorageHandler(mockFileAccessWrapper);
      final String expected = Image.file(imageFile).toString();

      // Act
      final String actual = await handler
          .getImage('assets/storagehandler_test_image.jpg')
          .then((value) => value.toString());

      // Assert
      expect(actual, expected);
    });

    // copyFile
    test('Copy File: should return the path of the new, copied file', () async {
      // Arrange
      File returnedFile = File('newFile');
      MockFileAccessWrapper mockFileAccessWrapper = MockFileAccessWrapper();
      when(mockFileAccessWrapper.copyFile(any, 'newPath'))
          .thenAnswer((invocation) => Future.value(returnedFile));
      StorageHandler handler = StorageHandler(mockFileAccessWrapper);

      // Act
      final String actual = await handler
          .copyFile(
              File('assets/storagehandler_test_image.jpg').path, 'newPath')
          .then((value) => value.path);

      // Assert
      expect(actual, 'newFile');
    });

    // deleteFile
    test('Delete File: Delete method should be called', () async {
      // Arrange
      MockFileAccessWrapper mockFileAccessWrapper = MockFileAccessWrapper();
      when(mockFileAccessWrapper.deleteFile(any)).thenAnswer(
          (invocation) => Future.value(File('placeholder_irrelevant')));
      StorageHandler handler = StorageHandler(mockFileAccessWrapper);

      // Act
      handler.deleteFile('assets/storagehandler_test_image.jpg');
      // final String actual = await handler.copyFile(File('assets/storagehandler_test_image.jpg').path, 'newPath').then((value) => value.path);

      // Assert
      verify(mockFileAccessWrapper.deleteFile(any)).called(1);
    });
  });

  group('Test Permission requests and granting', () {
    test('getPermission should return true -> Permission earlier granted...',
        () async {
      // Arrange
      MockPlatformWrapper mockPlatformWrapper = MockPlatformWrapper();
      when(mockPlatformWrapper.isGranted(Permission.storage))
          .thenAnswer((realInvocation) => Future.value(true));
      StorageHandler storageHandler = StorageHandler(FileAccessWrapper());

      // Act
      final actual = await storageHandler.getPermission(
          Permission.storage, mockPlatformWrapper);

      // Assert
      expect(actual, true);
      verifyNever(mockPlatformWrapper.request(any));
    });
    test(
        'getPermission should request permission after checking for it -> and then return false',
        () async {
      // Arrange
      MockPlatformWrapper mockPlatformWrapper = MockPlatformWrapper();
      when(mockPlatformWrapper.isGranted(Permission.storage))
          .thenAnswer((realInvocation) => Future.value(false));
      when(mockPlatformWrapper.request(Permission.storage)).thenAnswer(
          (realInvocation) => Future.value(
              PermissionStatus.denied)); // <-Permission denied by user
      StorageHandler storageHandler = StorageHandler(FileAccessWrapper());

      // Act
      final actual = await storageHandler.getPermission(
          Permission.storage, mockPlatformWrapper);

      // Assert
      expect(actual, false);
    });
    test(
        'getPermission should request permission after checking for it -> and then return true (granted)',
        () async {
      // Arrange
      MockPlatformWrapper mockPlatformWrapper = MockPlatformWrapper();
      when(mockPlatformWrapper.isGranted(Permission.storage))
          .thenAnswer((realInvocation) => Future.value(false));
      when(mockPlatformWrapper.request(Permission.storage)).thenAnswer(
          (realInvocation) => Future.value(
              PermissionStatus.granted)); // <-Permission granted by user
      StorageHandler storageHandler = StorageHandler(FileAccessWrapper());

      // Act
      final actual = await storageHandler.getPermission(
          Permission.storage, mockPlatformWrapper);

      // Assert
      expect(actual, true);
    });
  });
}
