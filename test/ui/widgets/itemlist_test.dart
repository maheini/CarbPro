import 'package:bloc_test/bloc_test.dart';
import 'package:carbpro/bloc/list_cubit/list_cubit.dart';
import 'package:carbpro/ui/widgets/itemlist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

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
          BlocProvider(
            create: (_) => listCubit,
            child: const ItemList(),
          ),
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });
    },
  );
}
