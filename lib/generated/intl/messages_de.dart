// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a de locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'de';

  static String m0(howMany) =>
      "${Intl.plural(howMany, one: '1 Element', other: '${howMany} Elemente')}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "add": MessageLookupByLibrary.simpleMessage("Hinzufügen"),
        "add_item": MessageLookupByLibrary.simpleMessage("Artikel hinzufügen"),
        "cancel": MessageLookupByLibrary.simpleMessage("Abbrechen"),
        "confirm": MessageLookupByLibrary.simpleMessage("Bestätigen"),
        "description": MessageLookupByLibrary.simpleMessage("Beschreibung"),
        "description_empty":
            MessageLookupByLibrary.simpleMessage("Beschreibung ist leer"),
        "edit_item": MessageLookupByLibrary.simpleMessage("Element bearbeiten"),
        "items_selected": m0,
        "language": MessageLookupByLibrary.simpleMessage("Deutsch"),
        "name": MessageLookupByLibrary.simpleMessage("Name"),
        "name_empty": MessageLookupByLibrary.simpleMessage("Name ist leer"),
        "ok": MessageLookupByLibrary.simpleMessage("Ok"),
        "remove": MessageLookupByLibrary.simpleMessage("Entfernen"),
        "save": MessageLookupByLibrary.simpleMessage("Speichern"),
        "search": MessageLookupByLibrary.simpleMessage("Suchen"),
        "storage_permission_missing": MessageLookupByLibrary.simpleMessage(
            "Fehlende Berechtigung für den Speicher"),
        "unknown_error": MessageLookupByLibrary.simpleMessage(
            "Ein unbekannter Fehler trat auf"),
        "warning_confirm_remove": MessageLookupByLibrary.simpleMessage(
            "Möchtest du des Element wirklich entfernen?")
      };
}
