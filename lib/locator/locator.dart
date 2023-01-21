import 'package:carbpro/handler/databasehandler.dart';
import 'package:get_it/get_it.dart';
import 'package:carbpro/handler/storagehandler.dart';

GetIt locator = GetIt.instance;

void setupLocator() {
  // Register all Storage access services
  locator
      .registerSingleton<StorageHandler>(StorageHandler(FileAccessWrapper()));

  locator.registerSingleton<DatabaseHandler>(DatabaseHandler(null));
}
