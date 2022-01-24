// Mocks generated by Mockito 5.0.17 from annotations
// in carbpro/test/storagehandler_test.dart.
// Do not manually edit this file.

import 'dart:async' as _i4;
import 'dart:io' as _i2;

import 'package:carbpro/storagehandler.dart' as _i3;
import 'package:mockito/mockito.dart' as _i1;
import 'package:permission_handler/permission_handler.dart' as _i5;

// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types

class _FakeRandomAccessFile_0 extends _i1.Fake implements _i2.RandomAccessFile {
}

class _FakeFile_1 extends _i1.Fake implements _i2.File {}

class _FakeFileSystemEntity_2 extends _i1.Fake implements _i2.FileSystemEntity {
}

/// A class which mocks [FileAccessWrapper].
///
/// See the documentation for Mockito's code generation for more information.
class MockFileAccessWrapper extends _i1.Mock implements _i3.FileAccessWrapper {
  MockFileAccessWrapper() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i4.Future<bool> exists(_i2.File? file) =>
      (super.noSuchMethod(Invocation.method(#exists, [file]),
          returnValue: Future<bool>.value(false)) as _i4.Future<bool>);
  @override
  _i4.Future<_i2.RandomAccessFile> openFile(_i2.File? file) =>
      (super.noSuchMethod(Invocation.method(#openFile, [file]),
              returnValue:
                  Future<_i2.RandomAccessFile>.value(_FakeRandomAccessFile_0()))
          as _i4.Future<_i2.RandomAccessFile>);
  @override
  _i4.Future<_i2.File> copyFile(_i2.File? file, String? newPath) =>
      (super.noSuchMethod(Invocation.method(#copyFile, [file, newPath]),
              returnValue: Future<_i2.File>.value(_FakeFile_1()))
          as _i4.Future<_i2.File>);
  @override
  _i4.Future<_i2.FileSystemEntity> deleteFile(_i2.File? file) =>
      (super.noSuchMethod(Invocation.method(#deleteFile, [file]),
              returnValue:
                  Future<_i2.FileSystemEntity>.value(_FakeFileSystemEntity_2()))
          as _i4.Future<_i2.FileSystemEntity>);
}

/// A class which mocks [PlatformWrapper].
///
/// See the documentation for Mockito's code generation for more information.
class MockPlatformWrapper extends _i1.Mock implements _i3.PlatformWrapper {
  MockPlatformWrapper() {
    _i1.throwOnMissingStub(this);
  }

  @override
  bool isAndroid() =>
      (super.noSuchMethod(Invocation.method(#isAndroid, []), returnValue: false)
          as bool);
  @override
  _i4.Future<bool> isGranted(_i5.Permission? permission) =>
      (super.noSuchMethod(Invocation.method(#isGranted, [permission]),
          returnValue: Future<bool>.value(false)) as _i4.Future<bool>);
  @override
  _i4.Future<_i5.PermissionStatus> request(_i5.Permission? permission) =>
      (super.noSuchMethod(Invocation.method(#request, [permission]),
              returnValue: Future<_i5.PermissionStatus>.value(
                  _i5.PermissionStatus.denied))
          as _i4.Future<_i5.PermissionStatus>);
}
