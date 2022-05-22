import 'package:bloc_test/bloc_test.dart';
import 'package:carbpro/bloc/list_cubit/list_cubit.dart';
import 'package:carbpro/datamodels/item.dart';
import 'package:carbpro/detailscreen.dart';
import 'package:carbpro/generated/l10n.dart';
import 'package:carbpro/ui/widgets/emtylistplaceholder.dart';
import 'package:carbpro/ui/widgets/itemlist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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

      testWidgets(
          'If the List is empty, ItemList should display '
          'a EmptyListPlaceholder, containing S.current.start_with_first_item',
          (WidgetTester tester) async {
        when(() => listCubit.state).thenReturn(
          const ListLoaded([], []),
        );

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: const [
              S.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: S.delegate.supportedLocales,
            home: BlocProvider(
              create: (_) => listCubit,
              child: const ItemList(),
            ),
          ),
        );
        await tester.pump();

        expect(find.byType(EmptyListPlaceholder), findsOneWidget);
        expect(find.text(S.current.start_with_first_item), findsOneWidget);
      });
    },
  );

  group(
    'List Tap / LongPress behaviour',
    () {
      late ListCubit listCubit;

      setUp(() {
        listCubit = MockListCubit();
      });

      testWidgets(
        'ItemList should call Navigator.push when an item is tapped',
        (WidgetTester tester) async {
          when(() => listCubit.state).thenReturn(
            ListLoaded(
              [Item(0, 'item1'), Item(1, 'item2')],
              const [],
            ),
          );

          bool settingsOpened = false;

          await tester.pumpWidget(
            MaterialApp(
              home: BlocProvider(
                create: (_) => listCubit,
                child: const ItemList(),
              ),
              onGenerateRoute: (settings) {
                if (settings.name == '/details') {
                  settingsOpened = true;
                  return MaterialPageRoute(
                      builder: (_) =>
                          DetailScreen(id: settings.arguments as int));
                }
                return null; // Let `onUnknownRoute` handle this behavior.
              },
            ),
          );

          await tester.tap(find.text('item1'));
          expect(settingsOpened, true);
          verifyNever(() => listCubit.itemPressed(any()));
        },
      );

      testWidgets(
        'listCubit.itemPressed should be called after lon-pressing an item',
        (WidgetTester tester) async {
          when(() => listCubit.state).thenReturn(
            ListLoaded(
              [Item(0, 'item1'), Item(1, 'item2')],
              const [],
            ),
          );

          bool settingsOpened = false;
          await tester.pumpWidget(
            MaterialApp(
              home: BlocProvider(
                create: (_) => listCubit,
                child: const ItemList(),
              ),
              onGenerateRoute: (settings) {
                if (settings.name == '/details') {
                  settingsOpened = true;
                  return MaterialPageRoute(
                      builder: (_) =>
                          DetailScreen(id: settings.arguments as int));
                }
                return null; // Let `onUnknownRoute` handle this behavior.
              },
            ),
          );

          await tester.longPress(find.text('item1'));

          verify(() => listCubit.itemPressed(0)).called(1);
          expect(settingsOpened, false);
        },
      );
    },
  );

  group(
    'List Selection (display & unselect)',
    () {
      late ListCubit listCubit;
      late ListSelection listSelection;

      setUp(() {
        listCubit = MockListCubit();
        listSelection = ListSelection(
          [Item(0, 'item1'), Item(1, 'item2')],
          const [0],
        );
      });

      testWidgets(
        'Check if one item is selected',
        (WidgetTester tester) async {
          when(() => listCubit.state).thenReturn(listSelection);

          await tester.pumpWidget(
            MaterialApp(
              home: BlocProvider(
                create: (_) => listCubit,
                child: const ItemList(),
              ),
            ),
          );

          Finder finder =
              find.byWidgetPredicate((w) => w is ListTile && w.selected);
          expect(finder, findsOneWidget);
        },
      );

      testWidgets(
        'cubit.itemPressed() should be called after a tap on a selected item',
        (WidgetTester tester) async {
          when(() => listCubit.state).thenReturn(listSelection);

          await tester.pumpWidget(
            MaterialApp(
              home: BlocProvider(
                create: (_) => listCubit,
                child: const ItemList(),
              ),
            ),
          );

          Finder finder =
              find.byWidgetPredicate((w) => w is ListTile && w.selected);
          expect(finder, findsOneWidget);

          await tester.tap(finder);
          verify(() => listCubit.itemPressed(0)).called(1);
        },
      );
    },
  );

  group(
    'List filtering',
    () {
      late ListCubit listCubit;
      late ListFiltered listFiltered;

      setUp(() {
        listCubit = MockListCubit();
        listFiltered = ListFiltered(
          'item1',
          [Item(0, 'item1')],
          const [0],
        );
      });
      testWidgets(
        'When ListFiltered is emitted, onyl filtered Items shoulb be visible',
        (WidgetTester tester) async {
          when(() => listCubit.state).thenReturn(listFiltered);

          await tester.pumpWidget(
            MaterialApp(
              home: BlocProvider(
                create: (_) => listCubit,
                child: const ItemList(),
              ),
            ),
          );

          expect(find.text('item1'), findsOneWidget);
          expect(find.text('item2'), findsNothing);
        },
      );
    },
  );
}
