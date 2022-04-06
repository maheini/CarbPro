import 'package:bloc_test/bloc_test.dart';
import 'package:carbpro/bloc/list_cubit/list_cubit.dart';
import 'package:carbpro/datamodels/item.dart';
import 'package:carbpro/handler/databasehandler.dart';
import 'package:carbpro/handler/storagehandler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDatabaseHandler extends Mock implements DatabaseHandler {}

class MockStorageHandler extends Mock implements StorageHandler {}

void main() {
  group(
    'Test Loading state of Listcubit',
    () {
      test(
        'Listcubitstate should be initially stat=Loading and nothing should really load',
        () {
          final DatabaseHandler databaseHandler = MockDatabaseHandler();
          when(() => databaseHandler.loadDatabase())
              .thenAnswer((_) async => true);
          when(() => databaseHandler.getItems())
              .thenAnswer((_) => Future.value([]));

          ListCubit cubit = ListCubit(databaseHandler);

          verifyNever(() => databaseHandler.getItems());
          expect(cubit.state is ListLoading, true);
          expect(cubit.state.items.length, 0);
          expect(cubit.state.selectedItems.length, 0);
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
        build: () => ListCubit(databaseHandler),
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
        build: () => ListCubit(databaseHandler),
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
      final DatabaseHandler databaseHandler = MockDatabaseHandler();
      when(() => databaseHandler.loadDatabase()).thenAnswer((_) async => true);
      final Item item1 = Item(1, 'Item1');
      final Item item2 = Item(2, 'Item2');
      List<Item> items = [item1, item2];

      when(() => databaseHandler.getItems()).thenAnswer(
        (_) => Future.value(items),
      );
      ListCubit cubit = ListCubit(databaseHandler);
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
          ListCubit cubit = ListCubit(databaseHandler);

          // load items
          cubit.loadItems();
          await expectLater(cubit.stream, emits(ListLoaded(items, const [])));

          // select item 0
          cubit.itemPressed(0);
          expect(cubit.state, ListSelection(items, const [0]));
        },
      );

      test(
        'After re-selecting the same item, the state should switch back to ListLoaded',
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
          ListCubit cubit = ListCubit(databaseHandler);

          // load items
          cubit.loadItems();
          await expectLater(cubit.stream, emits(ListLoaded(items, const [])));

          // select item 0
          cubit.itemPressed(0);
          expect(cubit.state, ListSelection(items, const [0]));

          cubit.itemPressed(0);
          expect(cubit.state, ListLoaded(items, const []));
        },
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
          ListCubit cubit = ListCubit(databaseHandler);

          // load items
          cubit.loadItems();
          await expectLater(cubit.stream, emits(ListLoaded(items, const [])));

          // select item 0
          cubit.itemPressed(0);
          expect(cubit.state, ListSelection(items, const [0]));

          cubit.itemPressed(1);
          expect(cubit.state, ListSelection(items, const [0, 1]));
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
          ListCubit cubit = ListCubit(databaseHandler);

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
          await cubit.itemPressed(5);
          expect(cubit.state, ListLoaded(items, const []));
        },
      );
    },
  );
}
