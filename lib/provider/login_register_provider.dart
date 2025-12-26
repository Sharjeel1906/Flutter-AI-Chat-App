import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../Cookies/api_client.dart';


class Login_Register_Provider extends ChangeNotifier {
  bool is_loading = false;
  bool is_loggedin = false;
  String name = "";
  // --- LOGIN ---
  Future<Map<String, String>> Login_user(String email, String password) async {
    try {
      is_loading = true;
      notifyListeners();
      Dio dio = await ApiClient.getClient();

      var response = await dio.post(
        "http://192.168.100.11:5000/login",
        //"http://127.0.0.1:5000/login",
        data: {"email": email, "password": password},
      );
      is_loading = false;
      notifyListeners();

      if (response.statusCode == 200 && response.data["status"] == "success") {
        is_loggedin = true;
        name = response.data["name"];
        notifyListeners(); // important for UI to rebuild
      }

      return {
        "code": "${response.statusCode}",
        "message": response.data["message"] ?? "No message",
      };
    } catch (e) {
      is_loading = false;
      notifyListeners();
      return {"code": "500", "message": "Something went wrong"};
    }
  }

  // --- LOGOUT ---
  Future<Map<String, String>> LogoutUser() async {
    try {
      Dio dio = await ApiClient.getClient();

      final response = await dio.post(
        'http://192.168.100.11:5000/logout',
        //"http://127.0.0.1:5000/logout",
        options: Options(
          headers: {
            "Content-Type": "application/json",
          },
        ),
      );
      is_loggedin= false;
      name = "";
      notifyListeners();
      return {
        "code": response.statusCode.toString(),
        "message": response.data["message"] ?? "Logged out",
      };
    } catch (e) {
      return {
        "code": "500",
        "message": "Something went wrong",
      };
    }
  }


  // --- REGISTER ---
  Future<Map<String, String>> RegisterUser(
      String name,
      String email,
      String password,
      ) async {
    try {
      is_loading = true;
      notifyListeners();
      var url = Uri.parse('http://192.168.100.11:5000/register');
      //var url = Uri.parse("http://127.0.0.1:5000/register",);
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"name": name, "email": email, "password": password}),
      );
      var res = jsonDecode(response.body);

      is_loading = false;
      notifyListeners();

      if (response.statusCode == 200) {
        is_loggedin = true;
        name = res.data["name"];
        notifyListeners(); // important for UI to rebuild
        return {
          "code": "${response.statusCode}",
          "message": "${res["message"]}",
        };
      } else {
        return {
          "code": "${response.statusCode}",
          "message": "${res["message"]}",
        };
      }
    } catch (e) {
      return {"code": "500", "message": "Something went wrong"};
    }
  }
}
