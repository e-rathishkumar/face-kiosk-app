import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/constants/api_constants.dart';
import 'data/datasources/local/local_storage.dart';
import 'data/datasources/remote/api_client.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/attendance_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/attendance_repository.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/attendance/attendance_bloc.dart';

final sl = GetIt.instance;

Future<void> setupDependencies() async {
  // External
  final prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(prefs);
  sl.registerSingleton<FlutterSecureStorage>(const FlutterSecureStorage());

  // Local Storage
  sl.registerSingleton<LocalStorage>(
    LocalStorage(
      secureStorage: sl<FlutterSecureStorage>(),
      prefs: sl<SharedPreferences>(),
    ),
  );

  // Dio
  final dio = Dio(BaseOptions(
    baseUrl: ApiConstants.baseUrl,
    connectTimeout: ApiConstants.connectTimeout,
    receiveTimeout: ApiConstants.receiveTimeout,
    sendTimeout: ApiConstants.sendTimeout,
    validateStatus: (status) => status != null && status < 500,
  ));

  // Auth interceptor
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      final token = await sl<LocalStorage>().getAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      handler.next(options);
    },
  ));

  // Log interceptor for debugging
  dio.interceptors.add(LogInterceptor(
    request: true,
    requestHeader: true,
    requestBody: true,
    responseHeader: true,
    responseBody: true,
    error: true,
  ));

  sl.registerSingleton<Dio>(dio);

  // API Client
  sl.registerSingleton<ApiClient>(ApiClient(sl<Dio>()));

  // Repositories
  sl.registerSingleton<AuthRepository>(
    AuthRepositoryImpl(
      apiClient: sl<ApiClient>(),
      localStorage: sl<LocalStorage>(),
    ),
  );

  sl.registerSingleton<AttendanceRepository>(
    AttendanceRepositoryImpl(apiClient: sl<ApiClient>()),
  );

  // BLoCs
  sl.registerFactory<AuthBloc>(
    () => AuthBloc(authRepository: sl<AuthRepository>()),
  );

  sl.registerFactory<AttendanceBloc>(
    () => AttendanceBloc(attendanceRepository: sl<AttendanceRepository>()),
  );
}
