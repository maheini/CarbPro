import 'package:bloc_test/bloc_test.dart';
import 'package:carbpro/datamodels/item.dart';
import 'package:carbpro/generated/l10n.dart';
import 'package:carbpro/ui/widgets/itemlist.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:mocktail/mocktail.dart';
import 'package:carbpro/ui/homescreen.dart';
import 'package:carbpro/handler/databasehandler.dart';
import 'package:carbpro/bloc/list_cubit/list_cubit.dart';

class MockDatabaseHandler extends Mock implements DatabaseHandler {}

class MockListCubit extends MockCubit<ListState> implements ListCubit {}

void main() {
  group('General UI layout & startup', () {
    late ListCubit listCubit;

    setUp(() {
      listCubit = MockListCubit();
      when(() => listCubit.state).thenReturn(ListLoading());
      when(() => listCubit.loadItems()).thenAnswer((_) async => true);
    });

    testWidgets('After App startup, ListCubit.loadItems should be called',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: HomeScreen(
          listCubit: listCubit,
        ),
      ));
      verify(() => listCubit.loadItems()).called(1);
    });

    testWidgets(
        'ListLoading: UI should only contain Appbar with title and ItemList'
        'And ItemList should display a ProgressIndicator if ListCubit is successfully registered.',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: HomeScreen(
          listCubit: listCubit,
        ),
      ));
      expect(find.text('CarbPro'), findsOneWidget);
      expect(find.byType(ItemList), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      expect(find.byIcon(Icons.search), findsNothing);
      expect(find.byType(FloatingActionButton), findsNothing);
    });
  });

  group(
    'Test Homescreen behaviour in ListLoaded state',
    () {
      late ListCubit listCubit;

      setUp(() {
        listCubit = MockListCubit();
        when(() => listCubit.state).thenReturn(const ListLoaded([], []));
        when(() => listCubit.loadItems()).thenAnswer((_) async => true);
      });

      testWidgets(
        'Homescreen should display a search & Add Button in ListLoaded state',
        (WidgetTester tester) async {
          await tester.pumpWidget(MaterialApp(
            home: HomeScreen(
              listCubit: listCubit,
            ),
          ));
          expect(find.byIcon(Icons.search), findsOneWidget);
          expect(find.byType(FloatingActionButton), findsOneWidget);
        },
      );

      testWidgets(
        'After tapping the search button, ListCubit.enableFilter should be called',
        (WidgetTester tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: HomeScreen(
                listCubit: listCubit,
              ),
            ),
          );
          expect(find.byIcon(Icons.search), findsOneWidget);
          expect(find.byType(FloatingActionButton), findsOneWidget);

          await tester.tap(find.byIcon(Icons.search));
          verify(() => listCubit.setFilter('')).called(1);
        },
      );
    },
  );

  group(
    'Test Homescreen in ListFiltered state',
    () {
      late ListCubit listCubit;

      setUp(() {
        listCubit = MockListCubit();
        when(() => listCubit.state).thenReturn(const ListFiltered('', [], []));
        when(() => listCubit.loadItems()).thenAnswer((_) async => true);
      });

      testWidgets(
        'Homescreen should display a floatingActionButton, searchBar & clear Button '
        'and no filter Button in ListFiltered state',
        (WidgetTester tester) async {
          await tester.pumpWidget(
            MaterialApp(
              localizationsDelegates: const [
                S.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: S.delegate.supportedLocales,
              home: HomeScreen(
                listCubit: listCubit,
              ),
            ),
          );
          await tester.pump();
          expect(find.byType(FloatingActionButton), findsOneWidget);
          expect(find.byIcon(Icons.search), findsNothing);
          expect(find.byIcon(Icons.clear), findsOneWidget);
          expect(find.byType(TextField), findsOneWidget);
          expect(find.text(S.current.search), findsOneWidget);
        },
      );

      testWidgets(
        'A change on SearchBar should call ListCubit.setFilter',
        (WidgetTester tester) async {
          await tester.pumpWidget(
            MaterialApp(
              localizationsDelegates: const [
                S.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: S.delegate.supportedLocales,
              home: HomeScreen(
                listCubit: listCubit,
              ),
            ),
          );
          await tester.pump();
          await tester.enterText(find.byType(TextField), '2');
          verify(() => listCubit.setFilter('2')).called(1);
        },
      );

      testWidgets(
        'A tap on clear button should call ListCubit.disableFilter',
        (WidgetTester tester) async {
          await tester.pumpWidget(
            MaterialApp(
              localizationsDelegates: const [
                S.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: S.delegate.supportedLocales,
              home: HomeScreen(
                listCubit: listCubit,
              ),
            ),
          );
          await tester.pump();
          await tester.tap(find.byIcon(Icons.clear));
          verify(() => listCubit.disableFilter()).called(1);
        },
      );

      testWidgets(
        'A simulated back button press should lead to a disableFilter call',
        (WidgetTester tester) async {
          await tester.pumpWidget(
            MaterialApp(
              localizationsDelegates: const [
                S.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: S.delegate.supportedLocales,
              home: HomeScreen(
                listCubit: listCubit,
              ),
            ),
          );
          await tester.pump();

          // Close Search bar by simulating a back button pressed
          final ByteData message = const JSONMethodCodec()
              .encodeMethodCall(const MethodCall('popRoute'));
          await ServicesBinding.instance!.defaultBinaryMessenger
              .handlePlatformMessage('flutter/navigation', message, (_) {});

          expect(find.byType(TextField), findsOneWidget);
          verify(() => listCubit.disableFilter()).called(1);
        },
      );
    },
  );

  group(
    'Test Homescreen in ListSelection state',
    () {
      late ListCubit listCubit;

      setUp(() {
        listCubit = MockListCubit();
        // simulate 1 loaded and 1 selected item
        when(() => listCubit.state)
            .thenReturn(ListSelection([Item(0, 'item1')], const [0]));
        when(() => listCubit.loadItems()).thenAnswer((_) async => true);
        when(() => listCubit.deleteSelection()).thenAnswer((_) async => true);
      });

      testWidgets(
        'Homescreen should display a floatingActionButton, '
        'delete icon and a text, counting the selected items',
        (WidgetTester tester) async {
          await tester.pumpWidget(
            MaterialApp(
              localizationsDelegates: const [
                S.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: S.delegate.supportedLocales,
              home: HomeScreen(
                listCubit: listCubit,
              ),
            ),
          );
          await tester.pump();

          expect(find.byType(FloatingActionButton), findsOneWidget);
          expect(find.byIcon(Icons.delete), findsOneWidget);
          expect(find.text(S.current.items_selected(1)), findsOneWidget);
        },
      );

