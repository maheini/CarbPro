// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
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
  String get localeName => 'en';

  static String m0(howMany) =>
      "${Intl.plural(howMany, one: '1 Item', other: '${howMany} Items')}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "about": MessageLookupByLibrary.simpleMessage("About CarbPro"),
        "add": MessageLookupByLibrary.simpleMessage("Add"),
        "add_item": MessageLookupByLibrary.simpleMessage("Add item"),
        "app_description": MessageLookupByLibrary.simpleMessage(
            "Carbpro is a great tool to create collections, e.g. image/carb collection for diabetics, image/name collection for mushroom picker... "),
        "app_developer_info": MessageLookupByLibrary.simpleMessage(
            "Carbpro is developed opensource by Martin Heini, supported by neofix.ch app development."),
        "build": MessageLookupByLibrary.simpleMessage("Build"),
        "camera": MessageLookupByLibrary.simpleMessage("Camera"),
        "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
        "confirm": MessageLookupByLibrary.simpleMessage("Confirm"),
        "description": MessageLookupByLibrary.simpleMessage("Description"),
        "description_empty":
            MessageLookupByLibrary.simpleMessage("Description is empty"),
        "download_items":
            MessageLookupByLibrary.simpleMessage("Download Items"),
        "edit_item": MessageLookupByLibrary.simpleMessage("Edit item"),
        "error_deleting_item":
            MessageLookupByLibrary.simpleMessage("Error deleting item(s)"),
        "export_failure": MessageLookupByLibrary.simpleMessage(
            "Export failed. Are all permissions granted?"),
        "export_success": MessageLookupByLibrary.simpleMessage(
            "all items were exported to /Downloads folder"),
        "gallery": MessageLookupByLibrary.simpleMessage("Gallery"),
        "github": MessageLookupByLibrary.simpleMessage("GitHub"),
        "import": MessageLookupByLibrary.simpleMessage("Import items"),
        "import_failure": MessageLookupByLibrary.simpleMessage(
            "Import aborted. Are all permissions granted?"),
        "items_selected": m0,
        "language": MessageLookupByLibrary.simpleMessage("English"),
        "name": MessageLookupByLibrary.simpleMessage("Name"),
        "name_empty": MessageLookupByLibrary.simpleMessage("Name is empty"),
        "ok": MessageLookupByLibrary.simpleMessage("Ok"),
        "remove": MessageLookupByLibrary.simpleMessage("Remove"),
        "save": MessageLookupByLibrary.simpleMessage("Save"),
        "search": MessageLookupByLibrary.simpleMessage("Search"),
        "start_with_first_item":
            MessageLookupByLibrary.simpleMessage("Start with your first Item"),
        "start_with_first_itemchild":
            MessageLookupByLibrary.simpleMessage("Now create a new entry"),
        "storage_permission_missing":
            MessageLookupByLibrary.simpleMessage("Storage access not granted"),
        "unknown_error":
            MessageLookupByLibrary.simpleMessage("An unknown error occurred"),
        "value": MessageLookupByLibrary.simpleMessage("Value"),
        "value_empty": MessageLookupByLibrary.simpleMessage("Value is empty"),
        "version": MessageLookupByLibrary.simpleMessage("Version"),
        "warning_confirm_remove": MessageLookupByLibrary.simpleMessage(
            "Do you really want to remove the item?"),
        "website": MessageLookupByLibrary.simpleMessage("Website"),
        "website_downloads_url": MessageLookupByLibrary.simpleMessage(
            "https://carbpro.neofix.ch/collection/"),
        "website_url":
            MessageLookupByLibrary.simpleMessage("https://carbpro.neofix.ch/"),
        "welcome": MessageLookupByLibrary.simpleMessage("Welcome")
      };
}
