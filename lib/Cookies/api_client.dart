import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class ApiClient {
  static Dio? _dio;
  static PersistCookieJar? _cookieJar;

  static Future<Dio> getClient() async {
    if (_dio == null) {
      _dio = Dio(BaseOptions(
        baseUrl:"http://192.168.100.11:5000", // replace with your backend URL
        headers: {"Content-Type": "application/json"},
      ));

      // Initialize persistent cookie jar
      Directory appDocDir = await getApplicationDocumentsDirectory();
      _cookieJar = PersistCookieJar(
        storage: FileStorage("${appDocDir.path}/.cookies/"),
      );

      // Add cookie manager interceptor
      _dio!.interceptors.add(CookieManager(_cookieJar!));
    }
    return _dio!;
  }
}
