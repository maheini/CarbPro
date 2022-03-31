import 'package:bloc_test/bloc_test.dart';
import 'package:carbpro/bloc/list_cubit/list_cubit.dart';
import 'package:carbpro/datamodels/item.dart';
import 'package:carbpro/handler/databasehandler.dart';
import 'package:carbpro/handler/storagehandler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'list_cubit_test.mocks.dart';

@GenerateMocks([DatabaseHandler, StorageHandler])
void main() {
  group(
    'Test Loading state of Listcubit',
    () {
      test(
        'Listcubitstate should be initially stat=Loading and nothing should really load',
        () {
          final DatabaseHandler databaseHandler = MockDatabaseHandler();
          when(databaseHandler.getItems()).thenAnswer((_) => Future.value([]));

          ListCubit cubit = ListCubit(databaseHandler);

          verifyNever(databaseHandler.getItems());
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
      final Item item1 = Item(1, 'Item1');
      final Item item2 = Item(2, 'Item2');
      final List<Item> items = [item1, item2];

      when(databaseHandler.getItems()).thenAnswer(
        (_) => Future.value(items),
      );

      blocTest(
        'After loading of the Items, ListLoaded should be emitted',
        build: () => ListCubit(databaseHandler),
        act: (ListCubit cubit) async {
          cubit.loadItems();
        },
        expect: () => [
          ListLoading(),
          ListLoaded(items, const []),
        ],
      );

  );
      );
      ListCubit cubit = ListCubit(databaseHandler);

      test(
        'The initial state of ListCubit is ListLoading',
        () {
          expect(cubit.state, ListLoading());
        },
      );

      test(
        'After loading the items, there should ListLoaded should be emitted, containing the items',
        () async {
          cubit.loadItems();

          await expectLater(
            cubit.stream,
            emits(
              ListLoaded([item1, item2], const []),
            ),
          );
        },
      );

      test(
        'When the items are reloaded, the state should switch back to ListLoading',
        () async {
          expect(cubit.state, ListLoaded([item1, item2], const []));
          cubit.loadItems();
          expect(cubit.state, ListLoading());
          expect(cubit.stream, emits(ListLoaded([item1, item2], const [])));
        },
      );
    },
  );
}
