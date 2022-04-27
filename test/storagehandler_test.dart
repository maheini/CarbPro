import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:carbpro/handler/storagehandler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class MockFileAccessWrapper extends Mock implements FileAccessWrapper {}

class MockPlatformWrapper extends Mock implements PlatformWrapper {}

class MockTarFileEncoder extends Mock implements TarFileEncoder {}

void main() {
  group('Test File Access', () {
    // TODO: add failing tests and implement exception handling

    setUp(
      () {
        registerFallbackValue(File('d'));
      },
    );

    // getImage
    test('Open Image: Should return a valid Image', () async {
      // Arrange
      File imageFile = File('assets/storagehandler_test_image.jpg');
      Future<RandomAccessFile> returnValue = imageFile.open();
      MockFileAccessWrapper mockFileAccessWrapper = MockFileAccessWrapper();
      when(() => mockFileAccessWrapper.openFile(any()))
          .thenAnswer((_) async => returnValue);
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
      when(() => mockFileAccessWrapper.copyFile(any(), 'newPath'))
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
      when(() => mockFileAccessWrapper.deleteFile(any())).thenAnswer(
          (invocation) => Future.value(File('placeholder_irrelevant')));
      // when(mockFileAccessWrapper.deleteFile(any)).thenAnswer(
      //     (invocation) => Future.value(File('placeholder_irrelevant')));
      StorageHandler handler = StorageHandler(mockFileAccessWrapper);

      // Act
      handler.deleteFile('assets/storagehandler_test_image.jpg');
      // final String actual = await handler.copyFile(File('assets/storagehandler_test_image.jpg').path, 'newPath').then((value) => value.path);

      // Assert
      verify(() => mockFileAccessWrapper.deleteFile(any())).called(1);
      // verify(mockFileAccessWrapper.deleteFile(any)).called(1);
    });
  });

  group('Test Permission requests and granting', () {
    setUp(
      () {
        registerFallbackValue(Permission.storage);
      },
    );

    test('getPermission should return true. Simulating permission granted',
        () async {
      // Arrange
      MockPlatformWrapper mockPlatformWrapper = MockPlatformWrapper();
      when(() => mockPlatformWrapper.isGranted(any()))
          .thenAnswer((_) async => true);
      StorageHandler storageHandler = StorageHandler(FileAccessWrapper());

      // Act
      final actual = await storageHandler.getPermission(
          Permission.storage, mockPlatformWrapper);

      // Assert
      expect(actual, true);
      verifyNever(() => mockPlatformWrapper.request(any()));
    });
    test(
        'getPermission should request permission after checking for it '
        '- and then return false', () async {
      // Arrange
      MockPlatformWrapper mockPlatformWrapper = MockPlatformWrapper();
      when(() => mockPlatformWrapper.isGranted(Permission.storage))
          .thenAnswer((realInvocation) => Future.value(false));
      when(() => mockPlatformWrapper.request(Permission.storage)).thenAnswer(
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
        'getPermission should request permission after checking for it - and then return true (granted)',
        () async {
      // Arrange
      MockPlatformWrapper mockPlatformWrapper = MockPlatformWrapper();
      when(() => mockPlatformWrapper.isGranted(Permission.storage))
          .thenAnswer((realInvocation) => Future.value(false));
      when(() => mockPlatformWrapper.request(Permission.storage)).thenAnswer(
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

  group(
    'Test export function',
    () {
      late PlatformWrapper mockPlatformWrapper;
      late TarFileEncoder mocktarFileEncoder;
      late FileAccessWrapper mockFileAccessWrapper;

      setUp(() {
        registerFallbackValue(Directory('d'));
        registerFallbackValue(File('d'));
        mockPlatformWrapper = MockPlatformWrapper();
        mocktarFileEncoder = MockTarFileEncoder();
        mockFileAccessWrapper = MockFileAccessWrapper();

        when(() =>
                mockPlatformWrapper.isGranted(Permission.manageExternalStorage))
            .thenAnswer((realInvocation) => Future.value(true));
        when(() => mockFileAccessWrapper.existsDir(any()))
            .thenAnswer((_) async => true);
      });

      test(
        'if there is no Permission granted, the function should return false',
        () async {
          when(() => mockPlatformWrapper
                  .isGranted(Permission.manageExternalStorage))
              .thenAnswer((realInvocation) => Future.value(false));

          StorageHandler storageHandler = StorageHandler(FileAccessWrapper());

          expect(
              await storageHandler.exportItems(
                  File('f'), [], mockPlatformWrapper),
              false);
        },
      );

}
