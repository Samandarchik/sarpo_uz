import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import '../data/local/app_storage.dart';
import '../data/local/base_storage.dart';
import '../data/local/shared_preferences_impl.dart';
import '../data/local/token_storage.dart';
import '../network/dio_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sl = GetIt.instance;

Future<void> setupInit() async {
  final SharedPreferences pref = await SharedPreferences.getInstance();

  /// register local storage
  sl.registerLazySingleton<BaseStorage>(() => SharedPreferencesImpl(pref));
  sl.registerLazySingleton<TokenStorage>(() => TokenStorage(sl<BaseStorage>()));
  sl.registerLazySingleton<AppStorage>(() => AppStorage(sl<BaseStorage>()));

  final dioClient = AppDioClient(tokenStorage: sl<TokenStorage>());
  final dio = dioClient.createDio();

  sl.registerLazySingleton<Dio>(() => dio);
}
