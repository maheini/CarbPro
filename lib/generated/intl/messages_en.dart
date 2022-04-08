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

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "add": MessageLookupByLibrary.simpleMessage("Add"),
        "add_item": MessageLookupByLibrary.simpleMessage("Add item"),
        "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
        "confirm": MessageLookupByLibrary.simpleMessage("Confirm"),
        "description": MessageLookupByLibrary.simpleMessage("Description"),
        "description_empty":
            MessageLookupByLibrary.simpleMessage("Description is empty"),
        "edit_item": MessageLookupByLibrary.simpleMessage("Edit item"),
        "language": MessageLookupByLibrary.simpleMessage("English"),
        "name": MessageLookupByLibrary.simpleMessage("Name"),
        "name_empty": MessageLookupByLibrary.simpleMessage("Name is empty"),
        "ok": MessageLookupByLibrary.simpleMessage("Ok"),
        "remove": MessageLookupByLibrary.simpleMessage("Remove"),
        "save": MessageLookupByLibrary.simpleMessage("Save"),
        "search": MessageLookupByLibrary.simpleMessage("Search"),
        "storage_permission_missing":
            MessageLookupByLibrary.simpleMessage("Storage access not granted"),
        "unknown_error":
            MessageLookupByLibrary.simpleMessage("An unknown error occurred"),
        "warning_confirm_remove": MessageLookupByLibrary.simpleMessage(
            "Do you really want to remove the item?")
      };
}
