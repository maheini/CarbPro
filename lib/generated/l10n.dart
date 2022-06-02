// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `English`
  String get language {
    return Intl.message(
      'English',
      name: 'language',
      desc: 'The current language',
      args: [],
    );
  }

  /// `Start with your first Item`
  String get start_with_first_item {
    return Intl.message(
      'Start with your first Item',
      name: 'start_with_first_item',
      desc: '',
      args: [],
    );
  }

  /// `Now create a new entry`
  String get start_with_first_itemchild {
    return Intl.message(
      'Now create a new entry',
      name: 'start_with_first_itemchild',
      desc: '',
      args: [],
    );
  }

  /// `Error deleting item(s)`
  String get error_deleting_item {
    return Intl.message(
      'Error deleting item(s)',
      name: 'error_deleting_item',
      desc: '',
      args: [],
    );
  }

  /// `An unknown error occurred`
  String get unknown_error {
    return Intl.message(
      'An unknown error occurred',
      name: 'unknown_error',
      desc: 'Text for unknown errors',
      args: [],
    );
  }

  /// `Confirm`
  String get confirm {
    return Intl.message(
      'Confirm',
      name: 'confirm',
      desc: 'Text title to confirm anything...',
      args: [],
    );
  }

  /// `Search`
  String get search {
    return Intl.message(
      'Search',
      name: 'search',
      desc: 'Text for search bars e.g.',
      args: [],
    );
  }

  /// `Add item`
  String get add_item {
    return Intl.message(
      'Add item',
      name: 'add_item',
      desc: 'Text for adding an item',
      args: [],
    );
  }

  /// `Name`
  String get name {
    return Intl.message(
      'Name',
      name: 'name',
      desc: 'Name text ',
      args: [],
    );
  }

  /// `Name is empty`
  String get name_empty {
    return Intl.message(
      'Name is empty',
      name: 'name_empty',
      desc: 'Message if name is empty',
      args: [],
    );
  }

  /// `Do you really want to remove the item?`
  String get warning_confirm_remove {
    return Intl.message(
      'Do you really want to remove the item?',
      name: 'warning_confirm_remove',
      desc: 'Warning text which is shown before removing an item',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
      desc: 'Cancel text',
      args: [],
    );
  }

  /// `Add`
  String get add {
    return Intl.message(
      'Add',
      name: 'add',
      desc: 'Text fot adding an item',
      args: [],
    );
  }

  /// `Remove`
  String get remove {
    return Intl.message(
      'Remove',
      name: 'remove',
      desc: 'Button text to remove a something',
      args: [],
    );
  }

  /// `{howMany, plural, one{1 Item} other{{howMany} Items}}`
  String items_selected(num howMany) {
    return Intl.plural(
      howMany,
      one: '1 Item',
      other: '$howMany Items',
      name: 'items_selected',
      desc: 'Text to display selected items',
      args: [howMany],
    );
  }

  /// `all items were exported to /Downloads folder`
  String get export_success {
    return Intl.message(
      'all items were exported to /Downloads folder',
      name: 'export_success',
      desc: '',
      args: [],
    );
  }

  /// `Export failed. Are all permissions granted?`
  String get export_failure {
    return Intl.message(
      'Export failed. Are all permissions granted?',
      name: 'export_failure',
      desc: '',
      args: [],
    );
  }

  /// `Import aborted. Are all permissions granted?`
  String get import_failure {
    return Intl.message(
      'Import aborted. Are all permissions granted?',
      name: 'import_failure',
      desc: '',
      args: [],
    );
  }

  /// `Import items`
  String get import {
    return Intl.message(
      'Import items',
      name: 'import',
      desc: '',
      args: [],
    );
  }

  /// `About CarbPro`
  String get about {
    return Intl.message(
      'About CarbPro',
      name: 'about',
      desc: '',
      args: [],
    );
  }

  /// `Download Items`
  String get download_items {
    return Intl.message(
      'Download Items',
      name: 'download_items',
      desc: '',
      args: [],
    );
  }

  /// `Storage access not granted`
  String get storage_permission_missing {
    return Intl.message(
      'Storage access not granted',
      name: 'storage_permission_missing',
      desc: 'Error message if there is no storage access granted',
      args: [],
    );
  }

  /// `Description`
  String get description {
    return Intl.message(
      'Description',
      name: 'description',
      desc: 'Translation for description :)',
      args: [],
    );
  }

  /// `Description is empty`
  String get description_empty {
    return Intl.message(
      'Description is empty',
      name: 'description_empty',
      desc: 'Message if description is empty',
      args: [],
    );
  }

  /// `Edit item`
  String get edit_item {
    return Intl.message(
      'Edit item',
      name: 'edit_item',
      desc: 'Text displayed for edit item buttons',
      args: [],
    );
  }

  /// `Save`
  String get save {
    return Intl.message(
      'Save',
      name: 'save',
      desc: 'Text for save button',
      args: [],
    );
  }

  /// `Ok`
  String get ok {
    return Intl.message(
      'Ok',
      name: 'ok',
      desc: 'Text for ok button',
      args: [],
    );
  }

  /// `Version`
  String get version {
    return Intl.message(
      'Version',
      name: 'version',
      desc: '',
      args: [],
    );
  }

  /// `Build`
  String get build {
    return Intl.message(
      'Build',
      name: 'build',
      desc: '',
      args: [],
    );
  }

  /// `Carbpro is a great tool to create collections, e.g. image/carb collection for diabetics, image/name collection for mushroom picker... `
  String get app_description {
    return Intl.message(
      'Carbpro is a great tool to create collections, e.g. image/carb collection for diabetics, image/name collection for mushroom picker... ',
      name: 'app_description',
      desc: '',
      args: [],
    );
  }

  /// `Carbpro is developed opensource by Martin Heini, supported by neofix.ch app development.`
  String get app_developer_info {
    return Intl.message(
      'Carbpro is developed opensource by Martin Heini, supported by neofix.ch app development.',
      name: 'app_developer_info',
      desc: '',
      args: [],
    );
  }

  /// `GitHub`
  String get github {
    return Intl.message(
      'GitHub',
      name: 'github',
      desc: '',
      args: [],
    );
  }

  /// `Website`
  String get website {
    return Intl.message(
      'Website',
      name: 'website',
      desc: '',
      args: [],
    );
  }

  /// `https://carbpro.neofix.ch/`
  String get website_url {
    return Intl.message(
      'https://carbpro.neofix.ch/',
      name: 'website_url',
      desc: '',
      args: [],
    );
  }

  /// `https://carbpro.neofix.ch/collection/`
  String get website_downloads_url {
    return Intl.message(
      'https://carbpro.neofix.ch/collection/',
      name: 'website_downloads_url',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'de'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
