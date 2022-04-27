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

      testWidgets(
        'A simulated back button press should lead to a cleared Selection',
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

          expect(find.text(S.current.items_selected(1)), findsOneWidget);
          verify(() => listCubit.clearSelection()).called(1);
        },
      );

      testWidgets(
        'After pressing the delete Icon, ListCubit.deleteSelection should be called',
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

          await tester.tap(find.byIcon(Icons.delete));
          verify(() => listCubit.deleteSelection()).called(1);
        },
      );

      testWidgets(
        'If ListCubit.deleteSelection returns false, a snackbar should be displayed',
        (WidgetTester tester) async {
          when(() => listCubit.deleteSelection())
              .thenAnswer((_) async => false);
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
          await tester.tap(find.byIcon(Icons.delete));
          await tester.pump();

          expect(find.text(S.current.error_deleting_item), findsOneWidget);
        },
      );
    },
  );

  group(
    'Test AddItem function of Homescreen',
    () {
      late ListCubit listCubit;

      setUp(() {
        listCubit = MockListCubit();
        // simulate 1 loaded item
        when(() => listCubit.state)
            .thenReturn(ListSelection([Item(1, 'item1')], const [0]));
        when(() => listCubit.loadItems()).thenAnswer((_) async => true);
      });

      testWidgets(
        'After a tap on Add, a Popup should appear, '
        'containing a Textfield and two buttons: add and cancel',
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

          await tester.tap(find.byIcon(Icons.add));
          await tester.pump();

          expect(find.byType(TextField), findsOneWidget);
          expect(find.text(S.current.add.toUpperCase()), findsOneWidget);
          expect(find.text(S.current.cancel.toUpperCase()), findsOneWidget);
        },
      );

      testWidgets(
        'After a tap on Cancel inside the popup, the popup should be closed '
        'and no item should be created',
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

          await tester.tap(find.byIcon(Icons.add));
          await tester.pump();
          await tester.enterText(find.byType(TextField), 'Test');
          await tester.tap(find.text(S.current.cancel.toUpperCase()));
          await tester.pump();

          expect(find.byType(TextField), findsNothing);
          expect(find.text(S.current.add.toUpperCase()), findsNothing);
          expect(find.text(S.current.cancel.toUpperCase()), findsNothing);
          verifyNever(() => listCubit.addItem(any()));
        },
      );

      testWidgets(
        'After a tap on Add inside the popup when there is no text, a warning should be displayed',
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

          await tester.tap(find.byIcon(Icons.add));
          await tester.pump();
          await tester.tap(find.text(S.current.add.toUpperCase()));
          await tester.pump();

          expect(find.byType(TextField), findsOneWidget);
          expect(find.text(S.current.name_empty), findsOneWidget);
          expect(find.text(S.current.add.toUpperCase()), findsOneWidget);
          expect(find.text(S.current.cancel.toUpperCase()), findsOneWidget);
          verifyNever(() => listCubit.addItem(any()));
        },
      );

      testWidgets(
        'If an Item is added, ListCubit.addItem should be called, '
        'then DetailScreen and lastly a reload should be triggered',
        (WidgetTester tester) async {
          when(() => listCubit.addItem(any())).thenAnswer((_) async => 1);
          when(() => listCubit.loadItems()).thenAnswer((_) async => true);

          int settingsId = 0;
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
              onGenerateRoute: (settings) {
                if (settings.name == '/details') {
                  settingsId = settings.arguments as int;
                  return MaterialPageRoute(
                    builder: (_) => Scaffold(appBar: AppBar()),
                  );
                }
                return null; // Let `onUnknownRoute` handle this behavior.
              },
            ),
          );
          await tester.pump();

          await tester.tap(find.byIcon(Icons.add));
          await tester.pump();
          await tester.enterText(find.byType(TextField), 'item1');
          await tester.tap(find.text(S.current.add.toUpperCase()));
          await tester.pump();

          // Return back
          final NavigatorState navigator = tester.state(find.byType(Navigator));
          navigator.pop();
          await tester.pump();

          expect(settingsId, 1);
          verify(() => listCubit.addItem('item1')).called(1);
          verify(() => listCubit.loadItems()).called(2);
        },
      );
    },
  );
}
