import 'package:flutter/cupertino.dart';
import 'package:dio/dio.dart';
import '../Cookies/api_client.dart';

class SessionsProvider extends ChangeNotifier {
  bool isLoading = false;
  bool _fetchedOnce = false;
  List<Map<String, dynamic>> sessions = [];

  void ResetSessions() {
    sessions.clear();
    _fetchedOnce = false;
    notifyListeners();
  }

  Future<void> getSessions() async {
    if (_fetchedOnce) return; // prevent multiple calls
    _fetchedOnce = true;

    isLoading = true;
    notifyListeners();

    try {
      Dio dio = await ApiClient.getClient();
      //final response = await dio.get("http://192.168.100.11:5000/sessions");
     // final response = await dio.get("http://127.0.0.1:5000/sessions");
       final response = await dio.get("https://aichatapp.pythonanywhere.com/sessions");

      if (response.statusCode == 200) {
        sessions = List<Map<String, dynamic>>.from(response.data);
      } else {
        sessions = [];
      }
    } catch (e) {
      sessions = [];
      debugPrint("Error fetching sessions: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
