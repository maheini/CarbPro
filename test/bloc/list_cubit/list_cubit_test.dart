import 'dart:io';
import 'package:bloc_test/bloc_test.dart';
import 'package:carbpro/bloc/list_cubit/list_cubit.dart';
import 'package:carbpro/datamodels/item.dart';
import 'package:carbpro/datamodels/itemchild.dart';
import 'package:carbpro/handler/databasehandler.dart';
import 'package:carbpro/handler/storagehandler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../storagehandler_test.dart';

class MockDatabaseHandler extends Mock implements DatabaseHandler {}

class MockStorageHandler extends Mock implements StorageHandler {}

void main() {
  setUpAll(
    () {
      registerFallbackValue(Permission.storage);
      registerFallbackValue(Permission);
      registerFallbackValue(MockPlatformWrapper());
    },
  );

  group(
    'Test Loading state of Listcubit',
    () {
      test(
        'Listcubitstate should be initially stat=Loading and nothing should really load, '
        'but DatabaseHandler.loadDatabase should be called',
        () async {
          final DatabaseHandler databaseHandler = MockDatabaseHandler();
          when(() => databaseHandler.loadDatabase())
              .thenAnswer((_) async => true);
          when(() => databaseHandler.getItems())
              .thenAnswer((_) => Future.value([]));
          ListCubit cubit = ListCubit(databaseHandler, MockStorageHandler());

          expect(cubit.state is ListLoading, true);
          expect(cubit.state.items.length, 0);
          expect(cubit.state.selectedIds.length, 0);
          verifyNever(() => databaseHandler.getItems());
          verify(() => databaseHandler.loadDatabase()).called(1);
        },
      );
    },
  );

  group(
    'Test Loading behaviour of ListCubit',
    () {
      final DatabaseHandler databaseHandler = MockDatabaseHandler();
      when(() => databaseHandler.loadDatabase()).thenAnswer((_) async => true);
      final Item item1 = Item(1, 'Item1');
      final Item item2 = Item(2, 'Item2');
      final List<Item> items = [item1, item2];

      when(() => databaseHandler.getItems()).thenAnswer(
        (_) => Future.value(items),
      );

      blocTest(
        'After loading of the Items, ListLoaded should be emitted',
        build: () => ListCubit(databaseHandler, MockStorageHandler()),
        act: (ListCubit cubit) async {
          await cubit.loadItems();
        },
        expect: () => [
          ListLoading(),
          ListLoaded(items, const []),
        ],
      );

      blocTest(
        'When the items are reloaded, the state should switch back to ListLoading',
        build: () => ListCubit(databaseHandler, MockStorageHandler()),
        act: (ListCubit cubit) async {
          await cubit.loadItems();
          cubit.loadItems();
        },
        expect: () => [
          ListLoading(),
          ListLoaded(items, const []),
          ListLoading(),
          ListLoaded(items, const []),
        ],
      );
    },
  );

  group(
    'Test ListCubit Selection behaviour',
    () {
      late DatabaseHandler databaseHandler;
      late ListCubit cubit;
      final Item item1 = Item(1, 'Item1');
      final Item item2 = Item(2, 'Item2');
      List<Item> items = [item1, item2];

      setUp(
        () {
          databaseHandler = MockDatabaseHandler();
          when(() => databaseHandler.loadDatabase())
              .thenAnswer((_) async => true);
          when(() => databaseHandler.getItems()).thenAnswer(
            (_) => Future.value(items),
          );

          cubit = ListCubit(databaseHandler, MockStorageHandler());
        },
      );

      blocTest(
        'load',
        build: () => cubit,
        act: (ListCubit bloc) {
          bloc.loadItems();
        },
        verify: (ListCubit cu) => cu.state == ListLoading(),
        expect: () => [
          ListLoading(),
          ListLoaded(items, const []),
        ],
      );

      test(
        'After selecting a Item, the State should change to ListSelection',
        () async {
          final DatabaseHandler databaseHandler = MockDatabaseHandler();
          when(() => databaseHandler.loadDatabase())
              .thenAnswer((_) async => true);
          final Item item1 = Item(1, 'Item1');
          final Item item2 = Item(2, 'Item2');
          List<Item> items = [item1, item2];

          when(() => databaseHandler.getItems()).thenAnswer(
            (_) => Future.value(items),
          );
          ListCubit cubit = ListCubit(databaseHandler, MockStorageHandler());

          // load items
          cubit.loadItems();
          await expectLater(cubit.stream, emits(ListLoaded(items, const [])));

          // select item 0
          cubit.itemPressed(1);
          expect(cubit.state, ListSelection(items, const [1]));
        },
      );

      blocTest(
        'If two items are selected and one got pressed, '
        'ListSelection should get emitted without this (unselected) item'
        'and if nothing is selected, ListLoaded should be emitted',
        build: () => cubit,
        act: (ListCubit cubit) async {
          await cubit.loadItems();
          cubit.itemPressed(1);
          cubit.itemPressed(2);
          cubit.itemPressed(2);
          cubit.itemPressed(1);
        },
        expect: () => [
          ListLoading(),
          ListLoaded(items, const []),
          ListSelection(items, const [1]),
          ListSelection(items, const [1, 2]),
          ListSelection(items, const [1]),
          ListLoaded(items, const []),
        ],
      );
      test(
        'Multiple (different) selection should change the selection and not the state',
        () async {
          final DatabaseHandler databaseHandler = MockDatabaseHandler();
          when(() => databaseHandler.loadDatabase())
              .thenAnswer((_) async => true);
          final Item item1 = Item(1, 'Item1');
          final Item item2 = Item(2, 'Item2');
          List<Item> items = [item1, item2];

          when(() => databaseHandler.getItems()).thenAnswer(
            (_) => Future.value(items),
          );
          ListCubit cubit = ListCubit(databaseHandler, MockStorageHandler());

          // load items
          cubit.loadItems();
          await expectLater(cubit.stream, emits(ListLoaded(items, const [])));

          // select item with id 1
          cubit.itemPressed(1);
          expect(cubit.state, ListSelection(items, const [1]));

          cubit.itemPressed(2);
          expect(cubit.state, ListSelection(items, const [1, 2]));
        },
      );

      test(
        'Failing test: If an Index out of range is selected, nothing should change',
        () async {
          final DatabaseHandler databaseHandler = MockDatabaseHandler();
          when(() => databaseHandler.loadDatabase())
              .thenAnswer((_) async => true);
          final Item item1 = Item(1, 'Item1');
          final Item item2 = Item(2, 'Item2');
          List<Item> items = [item1, item2];

          when(() => databaseHandler.getItems()).thenAnswer(
            (_) => Future.value(items),
          );
          ListCubit cubit = ListCubit(databaseHandler, MockStorageHandler());

          // load items
          expectLater(
            cubit.stream,
            emitsInOrder(
              [
                ListLoading(),
                ListLoaded(items, const []),
              ],
            ),
          );
          await cubit.loadItems();

          // select item out of range
          cubit.itemPressed(5);
          expect(cubit.state, ListLoaded(items, const []));
        },
      );

      blocTest(
        'After calling ListCubit.clearSelection in ListSelection State, '
        'the selection should be cleared',
        build: () => cubit,
        act: (ListCubit bloc) async {
          await bloc.loadItems();
          bloc.itemPressed(1);
          bloc.clearSelection();
        },
        verify: (ListCubit cu) => cu.state == ListLoading(),
        expect: () => [
          ListLoading(),
          ListLoaded(items, const []),
          ListSelection(items, const [1]),
          ListLoaded(items, const []),
        ],
      );

      blocTest(
        'After calling ListCubit.clearSelection in any other state than ListSelection, '
        'nothing should happen',
        build: () => cubit,
        act: (ListCubit bloc) async {
          bloc.clearSelection();
        },
        wait: const Duration(seconds: 2),
        verify: (ListCubit cu) => cu.state == ListLoading(),
        expect: () => [],
      );
    },
  );
  group('Test filtering Function of ListCubit', () {
    late DatabaseHandler databaseHandler;
    final List<Item> items = [Item(0, 'item1'), Item(1, 'item2')];
    setUp(() {
      databaseHandler = MockDatabaseHandler();
      when(() => databaseHandler.loadDatabase()).thenAnswer((_) async => true);
      when(() => databaseHandler.getItems())
          .thenAnswer((_) => Future.value(items));
    });

    blocTest(
      'ListFiltered should not be emitted if State == ListLoading',
      build: () => ListCubit(databaseHandler, MockStorageHandler()),
      act: (ListCubit cubit) => cubit.setFilter('test'),
      wait: const Duration(seconds: 2),
      expect: () => [],
    );

    blocTest(
      'After filtering ListCubit, ListFiltered should be emitted with one item',
      build: () => ListCubit(databaseHandler, MockStorageHandler()),
      act: (ListCubit cubit) async {
        await cubit.loadItems();
        cubit.setFilter('item1');
      },
      expect: () => [
        ListLoading(),
        ListLoaded(items, const []),
        ListFiltered('item1', [items.first], const []),
      ],
    );

    blocTest(
      'when Filter hasn\'t changed, ListFiltered should not be emitted',
      build: () => ListCubit(databaseHandler, MockStorageHandler()),
      act: (ListCubit cubit) async {
        await cubit.loadItems();
        cubit.setFilter('item1');
        cubit.setFilter('item1');
      },
      expect: () => [
        ListLoading(),
        ListLoaded(items, const []),
        ListFiltered('item1', [items.first], const []),
      ],
    );

    blocTest(
      'After disabling Filter, all Items should get loaded again',
      build: () => ListCubit(databaseHandler, MockStorageHandler()),
      act: (ListCubit cubit) async {
        await cubit.loadItems();
        cubit.setFilter('item1');
        cubit.disableFilter();
      },
      expect: () => [
        ListLoading(),
        ListLoaded(items, const []),
        ListFiltered('item1', [items.first], const []),
        ListLoaded(items, const []),
      ],
    );
  });

  group('Test the addItem function', () {
    late MockDatabaseHandler databaseHandler;

    setUp(() {
      databaseHandler = MockDatabaseHandler();
      when(() => databaseHandler.loadDatabase()).thenAnswer((_) async => true);
      when(() => databaseHandler.getItems())
          .thenAnswer((_) async => [Item(7, 'item7')]);
      when(() => databaseHandler.addItem(any())).thenAnswer((_) async => 1);
    });

    blocTest(
      'If the text is empty, DatabaseHandler.addItem should not be called',
      build: () => ListCubit(databaseHandler, MockStorageHandler()),
      act: (ListCubit cubit) async {
        await cubit.loadItems();
        await cubit.addItem('');
      },
      verify: (_) => verifyNever(() => databaseHandler.addItem(any())),
    );

    blocTest(
      'It the Item already exists, cubit should return the id',
      build: () => ListCubit(databaseHandler, MockStorageHandler()),
      act: (ListCubit cubit) async {
        await cubit.loadItems();
        expect(await cubit.addItem('ITem7'), 7);
      },
      verify: (_) => verifyNever(() => databaseHandler.addItem(any())),
    );

    blocTest(
      'It the Item doesn\'t exist, DatabaseHandler.addItem should be called',
      build: () => ListCubit(databaseHandler, MockStorageHandler()),
      act: (ListCubit cubit) async {
        await cubit.loadItems();
        expect(await cubit.addItem('test'), 1);
      },
      verify: (_) => verify(() => databaseHandler.addItem('test')).called(1),
    );
  });

  group('Test the deleteSelection function', () {
    List<Item> items = [Item(0, 'item1'), Item(1, 'item2')];
    List<ItemChild> child = [ItemChild(0, 1, '', 11.0, 'imagepath')];
    late MockDatabaseHandler databaseHandler;
    late MockStorageHandler storageHandler;

    setUp(() {
      databaseHandler = MockDatabaseHandler();
      storageHandler = MockStorageHandler();

      when(() => databaseHandler.loadDatabase()).thenAnswer((_) async => true);
      when(() => databaseHandler.getItems()).thenAnswer((_) async => items);
      when(() => databaseHandler.getChildren(1)).thenAnswer((_) async => child);
      when(() => databaseHandler.deleteAllChildren(1))
          .thenAnswer((_) async => 1);
      when(() => databaseHandler.deleteItem(1)).thenAnswer((_) async => 1);

      when(() => storageHandler.getPermission(any(), any()))
          .thenAnswer((_) async => true);
      when(() => storageHandler.getExternalStorageDirectory())
          .thenAnswer((_) async => Directory('hi'));
      when(() => storageHandler.deleteFile(any()))
          .thenAnswer((_) async => true);
    });

    blocTest(
      'If the state is not ListSelection, false should be returned '
      'and nothing should happen',
      build: () => ListCubit(databaseHandler, storageHandler),
      act: (ListCubit cubit) async {
        await cubit.loadItems();
        expect(await cubit.deleteSelection(), false);
      },
      verify: (_) =>
          verifyNever(() => storageHandler.getPermission(any(), any())),
    );

    blocTest(
      'Multiple functions should get called if the state is ListSelection',
      build: () => ListCubit(databaseHandler, storageHandler),
      act: (ListCubit cubit) async {
        await cubit.loadItems();
        cubit.itemPressed(1);
        expect(await cubit.deleteSelection(), true);
      },
      verify: (_) {
        verify(() => storageHandler.getExternalStorageDirectory()).called(1);
        verify(() => storageHandler.deleteFile('hi/imagepath')).called(1);
        verify(() => databaseHandler.getChildren(1)).called(1);
        verify(() => databaseHandler.deleteAllChildren(1)).called(1);
        verify(() => databaseHandler.deleteItem(1)).called(1);
      },
      expect: () => [
        ListLoading(),
        ListLoaded(items, const []),
        ListSelection(items, const [1]),
        ListLoading(),
        ListLoaded(items, const []),
      ],
    );

    blocTest(
      'If any exception occurs, nothing should happen and false should be returned',
      setUp: () =>
          when(() => storageHandler.deleteFile(any())).thenThrow(Exception()),
      build: () => ListCubit(databaseHandler, storageHandler),
      act: (ListCubit cubit) async {
        await cubit.loadItems();
        cubit.itemPressed(1);
        expect(await cubit.deleteSelection(), false);
      },
      verify: (_) {},
      expect: () => [
        ListLoading(),
        ListLoaded(items, const []),
        ListSelection(items, const [1]),
      ],
    );
  });

  group('Test the export function', () {
    List<Item> items = [Item(0, 'item1'), Item(1, 'item2')];
    List<ItemChild> child = [ItemChild(0, 1, '', 11.1, 'imagepath')];
    late MockDatabaseHandler databaseHandler;
    late MockStorageHandler storageHandler;

    setUp(() {
      databaseHandler = MockDatabaseHandler();
      storageHandler = MockStorageHandler();

      when(() => databaseHandler.loadDatabase()).thenAnswer((_) async => true);
      when(() => databaseHandler.getItems()).thenAnswer((_) async => items);
      when(() => databaseHandler.getChildren(1)).thenAnswer((_) async => child);

      when(() => storageHandler.getSdkVersion()).thenAnswer((_) async => 30);
      when(() => storageHandler.getPermission(
              Permission.manageExternalStorage, any()))
          .thenAnswer((_) async => false);
    });

    blocTest(
      'If the state is not ListSelection, false should be returned '
      'and nothing should happen',
      build: () => ListCubit(databaseHandler, storageHandler),
      act: (ListCubit cubit) async {
        await cubit.loadItems();
        expect(await cubit.export(), false);
      },
      verify: (_) =>
          verifyNever(() => storageHandler.getPermission(any(), any())),
    );

    blocTest(
      'ListCubit should check for the SDK version. If SDK is above 29, '
      'Permission.manageExternalStorage should be checked/requested',
      setUp: () {
        when(() => storageHandler.getSdkVersion()).thenAnswer((_) async => 30);
        when(() => storageHandler.getPermission(
                Permission.manageExternalStorage, any()))
            .thenAnswer((_) async => true);
      },
      build: () => ListCubit(databaseHandler, storageHandler),
      act: (ListCubit cubit) async {
        await cubit.loadItems();
        cubit.itemPressed(1);
        await cubit.export();
      },
      verify: (_) {
        verify(() => storageHandler.getSdkVersion()).called(1);
        verify(() => storageHandler.getPermission(
            Permission.manageExternalStorage, any())).called(1);
        verifyNever(
            () => storageHandler.getPermission(Permission.storage, any()));
      },
    );

    blocTest(
      'If Permission is denied for ManageExternalStorage, nothing should happen',
      setUp: () {
        when(() => storageHandler.getSdkVersion()).thenAnswer((_) async => 30);
        when(() => storageHandler.getPermission(
                Permission.manageExternalStorage, any()))
            .thenAnswer((_) async => false);
      },
      build: () => ListCubit(databaseHandler, storageHandler),
      act: (ListCubit cubit) async {
        await cubit.loadItems();
        cubit.itemPressed(1);
        expect(false, await cubit.export());
      },
      verify: (_) {
        verify(() => storageHandler.getSdkVersion()).called(1);
        verify(() => storageHandler.getPermission(
            Permission.manageExternalStorage, any())).called(1);
        verifyNever(
            () => storageHandler.getPermission(Permission.storage, any()));
      },
    );

    blocTest(
      'ListCubit should check for the SDK version. If SDK is equal or below 29, '
      'Permission.Storage should be checked/requested',
      setUp: () {
        when(() => storageHandler.getSdkVersion()).thenAnswer((_) async => 29);
        when(() => storageHandler.getPermission(Permission.storage, any()))
            .thenAnswer((_) async => true);
      },
      build: () => ListCubit(databaseHandler, storageHandler),
      act: (ListCubit cubit) async {
        await cubit.loadItems();
        cubit.itemPressed(1);
        await cubit.export();
      },
      verify: (_) {
        verify(() => storageHandler.getSdkVersion()).called(1);
        verify(() => storageHandler.getPermission(Permission.storage, any()))
            .called(1);
        verifyNever(() => storageHandler.getPermission(
            Permission.manageExternalStorage, any()));
      },
    );

    blocTest(
      'If Permission is denied for Storage, nothing should happen',
      setUp: () {
        when(() => storageHandler.getSdkVersion()).thenAnswer((_) async => 29);
        when(() => storageHandler.getPermission(Permission.storage, any()))
            .thenAnswer((_) async => false);
      },
      build: () => ListCubit(databaseHandler, storageHandler),
      act: (ListCubit cubit) async {
        await cubit.loadItems();
        cubit.itemPressed(1);
        expect(false, await cubit.export());
      },
      verify: (_) {
        verify(() => storageHandler.getSdkVersion()).called(1);
        verify(() => storageHandler.getPermission(Permission.storage, any()))
            .called(1);
        verifyNever(() => storageHandler.getPermission(
            Permission.manageExternalStorage, any()));
      },
    );

    blocTest(
      'If any exception occurs, nothing should happen and false should be returned',
      setUp: () =>
          when(() => databaseHandler.getChildren(any())).thenThrow(Exception()),
      build: () => ListCubit(databaseHandler, storageHandler),
      act: (ListCubit cubit) async {
        await cubit.loadItems();
        cubit.itemPressed(1);
        expect(await cubit.export(), false);
      },
    );

    late List<File> actualFiles;
    late String actualPath;
    late String actualJson;
    String expectedJson =
        '[{"name":"item2","children":[{"value":11.1,"description":"","imagepath":"imagepath"}]}]';
    blocTest(
        'The export function should call StorageHandler.export with appropriate arguments',
        setUp: () {
          when(() => storageHandler.getPermission(any(), any()))
              .thenAnswer((_) async => true);
          when(() => storageHandler.getExternalStorageDirectory())
              .thenAnswer((_) async => Directory('external'));
          when(() => storageHandler.deleteFile(any()))
              .thenAnswer((_) async => true);
          // Check if the exported values are correct
          when(() => storageHandler.exportItems(any(), any(), any(), any()))
              .thenAnswer((Invocation input) async {
            actualFiles = input.positionalArguments[2];
            actualPath = input.positionalArguments[1];
            actualJson = input.positionalArguments[0];
            return true;
          });
        },
        build: () => ListCubit(databaseHandler, storageHandler),
        act: (ListCubit cubit) async {
          await cubit.loadItems();
          cubit.itemPressed(1);

          expect(await cubit.export(), true);
          expect(
              actualFiles.isNotEmpty &&
                  actualFiles.first.path == 'external/${child.first.imagepath}',
              true);
          expect(actualPath, 'external');
          expect(actualJson, expectedJson);
        },
        expect: () => [
              ListLoading(),
              ListLoaded(items, const []),
              ListSelection(items, const [1]),
              ListLoaded(items, const []),
            ],
        verify: (_) {
          verify(() =>
                  storageHandler.exportItems(any(), 'external', any(), any()))
              .called(1);
        });

    blocTest('Cubit should return false if StorageHandler returned false',
        setUp: () {
          when(() => storageHandler.getPermission(any(), any()))
              .thenAnswer((_) async => true);
          when(() => storageHandler.getExternalStorageDirectory())
              .thenAnswer((_) async => Directory('external'));
          when(() => storageHandler.deleteFile(any()))
              .thenAnswer((_) async => true);
          // Check if the exported values are correct
          when(() => storageHandler.exportItems(any(), any(), any(), any()))
              .thenAnswer((Invocation input) async => false);
        },
        build: () => ListCubit(databaseHandler, storageHandler),
        act: (ListCubit cubit) async {
          await cubit.loadItems();
          cubit.itemPressed(1);

          expect(await cubit.export(), false);
        },
        wait: const Duration(seconds: 3),
        expect: () => [
              ListLoading(),
              ListLoaded(items, const []),
              ListSelection(items, const [1]),
            ],
        verify: (_) {
          verify(() => storageHandler.exportItems(any(), any(), any(), any()))
              .called(1);
        });
  });

  group('Test the import function', () {
    String json =
        '[{"name":"item1","children":[{"value":11.1,"description":"desc","imagepath":"imagepath"}]}]';
    List<Item> items = [Item(1, 'item1')];
    late Directory temp;
    late Directory external;
    late Directory import;
    late MockDatabaseHandler databaseHandler;
    late MockStorageHandler storageHandler;
    late MockFileAccessWrapper fileAccessWrapper;

    setUp(() {
      registerFallbackValue(Directory(''));
      registerFallbackValue(File(''));
      registerFallbackValue(ItemChild(1, 0, 'description', 11.1, 'imagepath'));

      temp = Directory('temp');
      external = Directory('external');
      import = Directory('import');

      databaseHandler = MockDatabaseHandler();
      storageHandler = MockStorageHandler();
      fileAccessWrapper = MockFileAccessWrapper();

      when(() => storageHandler.getTempStorageDirectory())
          .thenAnswer((_) async => temp);
      when(() => storageHandler.getExternalStorageDirectory())
          .thenAnswer((_) async => external);
      when(() => storageHandler.import(any(), any()))
          .thenAnswer((_) async => import);
      when(() => storageHandler.copyFile(any(), any())).thenAnswer(
          (invocation) async => File(invocation.positionalArguments[1]));

      when(() => fileAccessWrapper.readFile(any())).thenAnswer((_) async {
        return '{"name":"item2","children":[{"value":11.1,"description":"","imagepath":"imagepath"}]}';
      });
      when(() => fileAccessWrapper.exists(any())).thenAnswer((val) async {
        File file = val.positionalArguments[0];
        // return false to simulate that the image isn't imported already
        if (file.path == '${external.path}/imagepath') {
          return false;
        }
        return true;
      });
      when(() => fileAccessWrapper.readFile(any()))
          .thenAnswer((_) async => json);

      when(() => databaseHandler.loadDatabase()).thenAnswer((_) async => true);
      when(() => databaseHandler.getItems()).thenAnswer((_) async => items);
      when(() => databaseHandler.addItem(any())).thenAnswer((_) async => 1);
      when(() => databaseHandler.addItemChild(any()))
          .thenAnswer((_) async => 1);
    });

    blocTest(
      'If external storage returns null, nothing should happen and false should be returned',
      setUp: () => when(() => storageHandler.getExternalStorageDirectory())
          .thenAnswer((_) async => null),
      build: () => ListCubit(databaseHandler, storageHandler),
      act: (ListCubit cubit) async {
        await cubit.loadItems();
        cubit.itemPressed(1);
        expect(await cubit.import(MockFileAccessWrapper()), false);
      },
      verify: (_) {
        verify(() => storageHandler.getExternalStorageDirectory()).called(1);
      },
    );
    blocTest(
      'If temporary storage returns null, nothing should happen and false should be returned',
      setUp: () => when(() => storageHandler.getTempStorageDirectory())
          .thenAnswer((_) async => null),
      build: () => ListCubit(databaseHandler, storageHandler),
      act: (ListCubit cubit) async {
        await cubit.loadItems();
        cubit.itemPressed(1);
        expect(await cubit.import(MockFileAccessWrapper()), false);
      },
      verify: (_) {
        verify(() => storageHandler.getTempStorageDirectory()).called(1);
      },
    );

    blocTest(
        'There should be a call to storageHandler.import with acoording dir '
        'and if import returns false, nothing should happen and false should be returned',
        setUp: () {
          when(() => storageHandler.import(any(), any()))
              .thenAnswer((_) async => null);
        },
        build: () => ListCubit(databaseHandler, storageHandler),
        act: (ListCubit cubit) async {
          await cubit.loadItems();
          cubit.itemPressed(1);
          expect(await cubit.import(MockFileAccessWrapper()), false);
        },
        verify: (_) {
          verify(() => storageHandler.import(external, temp)).called(1);
        });

    late bool hasCalledItemsJson;
    blocTest(
        'There should be a check if the items.json exists '
        'inside the import dir',
        setUp: () {
          hasCalledItemsJson = false;
          when(() => fileAccessWrapper.exists(any())).thenAnswer((val) async {
            File file = val.positionalArguments[0];
            if (file.path == '${import.path}/items.json') {
              hasCalledItemsJson = true;
            }
            // return false to simulate that the image isn't imported already
            if (file.path == '${external.path}/imagepath') {
              return false;
            }
            return true;
          });
        },
        build: () => ListCubit(databaseHandler, storageHandler),
        act: (ListCubit cubit) async {
          expect(await cubit.import(fileAccessWrapper), true);
          expect(hasCalledItemsJson, true);
        },
        verify: (_) {
          verify(() => fileAccessWrapper.exists(any())).called(2);
        });

    late bool hasCheckedImageFile;
    blocTest(
      'After the items.json check, there should be a check for all images inside temp storage',
      setUp: () {
        hasCheckedImageFile = false;
        when(() => fileAccessWrapper.exists(any())).thenAnswer((val) async {
          File file = val.positionalArguments[0];
          if (file.path == '${import.path}/imagepath') {
            hasCheckedImageFile = true;
          }
          return true;
        });
      },
      build: () => ListCubit(databaseHandler, storageHandler),
      act: (ListCubit cubit) async {
        expect(await cubit.import(fileAccessWrapper), true);
        expect(hasCheckedImageFile, true);
      },
      verify: (_) {
        verify(() => fileAccessWrapper.exists(any())).called(2);
        verify(() => fileAccessWrapper.readFile(any())).called(1);
      },
    );

    blocTest(
      'After all checks, DatabaseHandler and fileAccessWrapper should now '
      'be called multiple times and the list should be updated',
      build: () => ListCubit(databaseHandler, storageHandler),
      act: (ListCubit cubit) async {
        await cubit.loadItems();
        expect(await cubit.import(fileAccessWrapper), true);
      },
      expect: () => [
        ListLoading(),
        ListLoaded(items, const []),
        ListLoading(),
        isA<ListLoaded>(),
      ],
      verify: (_) {
        verify(() => databaseHandler.addItem(any())).called(1);
        verify(() => storageHandler.copyFile(any(), any())).called(1);
        verify(() => databaseHandler.addItemChild(any())).called(1);
      },
    );

    blocTest(
      'On a error in e.g. the databaseHandler, nothing should happen and false should be returned',
      setUp: () {
        when(() => databaseHandler.addItem(any())).thenThrow(Exception());
      },
      build: () => ListCubit(databaseHandler, storageHandler),
      act: (ListCubit cubit) async {
        expect(await cubit.import(fileAccessWrapper), false);
      },
      expect: () => [],
      verify: (_) {
        verify(() => databaseHandler.addItem(any())).called(1);
      },
    );
  });

  group('Test firstload functions', () {
    late Directory temp;
    late Directory external;
    late Directory import;

    late DatabaseHandler databaseHandler;
    late StorageHandler storageHandler;
    late FileAccessWrapper fileAccessWrapper;
    late PlatformWrapper platformWrapper;

    setUp(() {
      registerFallbackValue(Directory(''));
      registerFallbackValue(File(''));
      registerFallbackValue(ItemChild(1, 0, 'description', 11.0, 'imagepath'));

      temp = Directory('temp');
      external = Directory('external');
      import = Directory('import');

      databaseHandler = MockDatabaseHandler();
      storageHandler = MockStorageHandler();
      fileAccessWrapper = MockFileAccessWrapper();
      platformWrapper = MockPlatformWrapper();

      when(() => storageHandler.getTempStorageDirectory())
          .thenAnswer((_) async => temp);
      when(() => storageHandler.getExternalStorageDirectory())
          .thenAnswer((_) async => external);
      when(() => storageHandler.import(any(), any()))
          .thenAnswer((_) async => import);
      when(() => storageHandler.copyFile(any(), any())).thenAnswer(
          (invocation) async => File(invocation.positionalArguments[1]));

      when(() => fileAccessWrapper.readFile(any())).thenAnswer((_) async =>
          '{"name":"item2","children":[{"description":"","imagepath":"imagepath"}]}');
      when(() => fileAccessWrapper.exists(any())).thenAnswer((val) async {
        File file = val.positionalArguments[0];
        // return false to simulate that the image isn't imported already
        if (file.path == '${external.path}/imagepath') {
          return false;
        }
        return true;
      });

      when(() => databaseHandler.loadDatabase()).thenAnswer((_) async => true);

      // real data
      when(() => platformWrapper.getPreference('carbpro_version'))
          .thenAnswer((_) async => '1');
      when(() => platformWrapper.setPreference('carbpro_version', '1'))
          .thenAnswer((_) async => true);
      when(() => platformWrapper.getAppVersion()).thenAnswer((_) async => '1');

      // Folders
      when(() => storageHandler.getExternalStorageDirectory())
          .thenAnswer((invocation) async => external);
      when(() => storageHandler.getTempStorageDirectory())
          .thenAnswer((invocation) async => temp);
    });

    blocTest(
      'Firstload should call Plattformwrapper and check if the app was opened '
      'before and return if if was opened before',
      build: () => ListCubit(databaseHandler, storageHandler),
      act: (ListCubit cubit) async {
        await cubit.checkForFirstLoad(
            wrapper: platformWrapper, fileAccessWrapper: fileAccessWrapper);
      },
      expect: () => [],
      verify: (_) {
        verify(() => platformWrapper.getPreference('carbpro_version'))
            .called(1);
        verifyNever(() => platformWrapper.setPreference(any(), any()));
        verifyNever(() => storageHandler.getTempStorageDirectory());
      },
    );

    blocTest(
      'If the PlatformWrapper returns null, temp and external directory should be requested',
      setUp: () {
        when(() => platformWrapper.getPreference(any()))
            .thenAnswer((_) async => null);
      },
      build: () => ListCubit(databaseHandler, storageHandler),
      act: (ListCubit cubit) async {
        await cubit.checkForFirstLoad(
            wrapper: platformWrapper, fileAccessWrapper: fileAccessWrapper);
      },
      expect: () => [],
      verify: (_) {
        verify(() => platformWrapper.getPreference('carbpro_version'))
            .called(1);
        verify(() => storageHandler.getTempStorageDirectory())
            .called(greaterThan(0));
        verify(() => storageHandler.getExternalStorageDirectory())
            .called(greaterThan(0));
      },
    );

    blocTest(
      'If the PlatformWrapper returns an empty String'
      ', temp and external directory should be requested',
      setUp: () {
        when(() => platformWrapper.getPreference(any()))
            .thenAnswer((_) async => null);
      },
      build: () => ListCubit(databaseHandler, storageHandler),
      act: (ListCubit cubit) async {
        await cubit.checkForFirstLoad(
            wrapper: platformWrapper, fileAccessWrapper: fileAccessWrapper);
      },
      expect: () => [],
      verify: (_) {
        verify(() => platformWrapper.getPreference('carbpro_version'))
            .called(1);
        verify(() => storageHandler.getTempStorageDirectory())
            .called(greaterThan(0));
        verify(() => storageHandler.getExternalStorageDirectory())
            .called(greaterThan(0));
      },
    );
  });
}
