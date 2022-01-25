import 'package:get_it/get_it.dart';
import 'package:carbpro/handler/storagehandler.dart';

GetIt locator = GetIt.instance();

void setupLocator(){
  locator.registerSingleton<StorageHandler>(StorageHandler(FileAccessWrapper()));
}