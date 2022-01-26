import 'package:carbpro/handler/databasehandler.dart';
import 'package:get_it/get_it.dart';
import 'package:carbpro/handler/storagehandler.dart';

GetIt locator = GetIt.instance;

void setupLocator()async {
  // Register all Storage access services
  locator.registerSingleton<StorageHandler>(StorageHandler(FileAccessWrapper()));

  // Register all Database access services
  locator.registerSingletonAsync<DatabaseHandler>(() async {
    return DatabaseHandler(await DatabaseHandler.addDatabase());
  }, signalsReady: true);
}