import 'package:carbpro/newmain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

// flutter pub run build_runner build --delete-conflicting-outputs

// @GenerateMocks([CarbPro])
void main(){
  group('App startup', () {
    testWidgets('Open the App and check for basic design elements', (WidgetTester tester) async{
      await tester.pumpWidget(const CarbPro());

      expect(find.byType (AlertDialog), findsNothing);
      expect(find.text('CarbPro'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });


  });
}