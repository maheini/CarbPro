import 'package:bloc_test/bloc_test.dart';
import 'package:carbpro/bloc/list_cubit/list_cubit.dart';
import 'package:carbpro/datamodels/item.dart';
import 'package:carbpro/detailscreen.dart';
import 'package:carbpro/ui/widgets/itemlist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MockListCubit extends MockCubit<ListState> implements ListCubit {}

void main() {
  group(
    'List Loading and Display',
    () {
      late ListCubit listCubit;

      setUp(() {
        listCubit = MockListCubit();
      });

      testWidgets(
          'If the List is loading, then only a CircularProgressIndicator should be visible',
          (WidgetTester tester) async {
        when(() => listCubit.state).thenReturn(ListLoading());

        expect(listCubit.state, ListLoading());

        verifyNever(() => listCubit.loadItems());

        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider(
              create: (_) => listCubit,
              child: const ItemList(),
            ),
          ),
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('ItemList should display two Items after its loaded',
          (WidgetTester tester) async {
        when(() => listCubit.state).thenReturn(
          ListLoaded(
            [Item(0, 'item1'), Item(1, 'item2')],
            const [],
          ),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider(
              create: (_) => listCubit,
              child: const ItemList(),
            ),
          ),
        );

        expect(find.text('item1'), findsOneWidget);
        expect(find.text('item2'), findsOneWidget);
      });
    },
  );
    },
  );
}
