import 'package:get_it/get_it.dart';
import 'package:plasco/services/constants.dart';
import 'package:plasco/services/web.dart';

GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton(() => Constants());
  locator.registerLazySingleton(() => Web());
}
