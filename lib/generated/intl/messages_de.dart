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
        "about": MessageLookupByLibrary.simpleMessage("Über CarbPro"),
        "add": MessageLookupByLibrary.simpleMessage("Hinzufügen"),
        "add_item": MessageLookupByLibrary.simpleMessage("Element hinzufügen"),
        "app_description": MessageLookupByLibrary.simpleMessage(
            "Carbpro ist ein großartiges Tool zum Erstellen von Sammlungen, z.B. Bild/Kohlenhydrat-Sammlung für Diabetiker, Bild/Name-Sammlung für Pilzsammler... "),
        "app_developer_info": MessageLookupByLibrary.simpleMessage(
            "Carbpro wurde von Martin Heini entwickelt, unterstützt durch neofix.ch App Entwicklung."),
        "build": MessageLookupByLibrary.simpleMessage("Build"),
        "camera": MessageLookupByLibrary.simpleMessage("Kamera"),
        "cancel": MessageLookupByLibrary.simpleMessage("Abbrechen"),
        "confirm": MessageLookupByLibrary.simpleMessage("Bestätigen"),
        "description": MessageLookupByLibrary.simpleMessage("Beschreibung"),
        "description_empty":
            MessageLookupByLibrary.simpleMessage("Beschreibung ist leer"),
        "download_items":
            MessageLookupByLibrary.simpleMessage("Elemente herunterladen"),
        "edit_item": MessageLookupByLibrary.simpleMessage("Element bearbeiten"),
        "error_deleting_item": MessageLookupByLibrary.simpleMessage(
            "Fehler beim Löschen der Einträge"),
        "export_failure": MessageLookupByLibrary.simpleMessage(
            "Export fehlgeschlagen. Sind alle Berechtigungen erlaubt?"),
        "export_success": MessageLookupByLibrary.simpleMessage(
            "Alle Elemente wurden exportiert in den /downloads Ordner"),
        "gallery": MessageLookupByLibrary.simpleMessage("Galerie"),
        "github": MessageLookupByLibrary.simpleMessage("GitHub"),
        "import": MessageLookupByLibrary.simpleMessage("Elemente importieren"),
        "import_failure": MessageLookupByLibrary.simpleMessage(
            "Import abgebrochen. Sind alle Berechtigungen erlaubt?"),
        "items_selected": m0,
        "language": MessageLookupByLibrary.simpleMessage("Deutsch"),
        "name": MessageLookupByLibrary.simpleMessage("Name"),
        "name_empty": MessageLookupByLibrary.simpleMessage("Name ist leer"),
        "ok": MessageLookupByLibrary.simpleMessage("Ok"),
        "remove": MessageLookupByLibrary.simpleMessage("Entfernen"),
        "save": MessageLookupByLibrary.simpleMessage("Speichern"),
        "search": MessageLookupByLibrary.simpleMessage("Suchen"),
        "start_with_first_item": MessageLookupByLibrary.simpleMessage(
            "Starte mit deinem ersten Element"),
        "start_with_first_itemchild":
            MessageLookupByLibrary.simpleMessage("Erstelle nun einen Eintrag"),
        "storage_permission_missing": MessageLookupByLibrary.simpleMessage(
            "Fehlende Berechtigung für den Speicher"),
        "unknown_error": MessageLookupByLibrary.simpleMessage(
            "Ein unbekannter Fehler trat auf"),
        "value": MessageLookupByLibrary.simpleMessage("Wert"),
        "value_empty": MessageLookupByLibrary.simpleMessage("Wert ist leer"),
        "version": MessageLookupByLibrary.simpleMessage("Version"),
        "warning_confirm_remove": MessageLookupByLibrary.simpleMessage(
            "Möchtest du des Element wirklich entfernen?"),
        "website": MessageLookupByLibrary.simpleMessage("Website"),
        "website_downloads_url": MessageLookupByLibrary.simpleMessage(
            "https://carbpro.neofix.ch/de/sammlung/"),
        "website_url": MessageLookupByLibrary.simpleMessage(
            "https://carbpro.neofix.ch/de/"),
        "welcome": MessageLookupByLibrary.simpleMessage("Willkommen")
      };
}
