import 'package:bloc_test/bloc_test.dart';
import 'package:carbpro/bloc/list_cubit/list_cubit.dart';
import 'package:carbpro/datamodels/item.dart';
import 'package:carbpro/handler/databasehandler.dart';
import 'package:carbpro/handler/storagehandler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import '../../detailscreen_test.mocks.dart';

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

}
