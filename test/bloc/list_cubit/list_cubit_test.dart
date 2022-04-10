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
        'Listcubitstate should be initially stat=Loading and nothing should really load, '
        'but DatabaseHandler.loadDatabase should be called',
        () async {
          final DatabaseHandler databaseHandler = MockDatabaseHandler();
          when(() => databaseHandler.loadDatabase())
              .thenAnswer((_) async => true);
          when(() => databaseHandler.getItems())
              .thenAnswer((_) => Future.value([]));
          ListCubit cubit = ListCubit(databaseHandler);

          expect(cubit.state is ListLoading, true);
          expect(cubit.state.items.length, 0);
          expect(cubit.state.selectedItems.length, 0);
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
          when(() => databaseHandler.getItems()).thenAnswer(
            (_) => Future.value(items),
          );

          cubit = ListCubit(databaseHandler);
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
          bloc.itemPressed(0);
          bloc.clearSelection();
        },
        verify: (ListCubit cu) => cu.state == ListLoading(),
        expect: () => [
          ListLoading(),
          ListLoaded(items, const []),
          ListSelection(items, const [0]),
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
      build: () => ListCubit(databaseHandler),
      act: (ListCubit cubit) => cubit.setFilter('test'),
      wait: const Duration(seconds: 2),
      expect: () => [],
    );

    blocTest(
      'After filtering ListCubit, ListFiltered should be emitted with one item',
      build: () => ListCubit(databaseHandler),
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
      build: () => ListCubit(databaseHandler),
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
      build: () => ListCubit(databaseHandler),
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
}
