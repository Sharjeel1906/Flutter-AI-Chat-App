import 'package:flutter/cupertino.dart';
import '../Cookies/api_client.dart';

class ChatProvider extends ChangeNotifier {
  int? _sessionId;
  List<Map<String, dynamic>> messages = [];
  String? sessionTitle;
  bool isLoading = false;

  int? get session_id => _sessionId;


  Future<void> GetResponse(String message) async {
    try {
      isLoading = true;
      notifyListeners();

      final dio = await ApiClient.getClient();

      final response = await dio.post(
        //"http://192.168.100.11:5000/chat",
        "https://aichatapp.pythonanywhere.com/chat",

        data: {
          "message": message,
          if (_sessionId != null) "session_id": _sessionId,
        },
      );

      final res = response.data;

      // Update session id (new or existing)
      _sessionId = res["session_id"];

      // 🔑 THIS LINE FIXES EVERYTHING
      // Fetch messages from DB (user + assistant)
      await GetMessages(_sessionId!);

    } catch (e) {
      messages.add({
        "role": "model",
        "message": "Error fetching AI response",
      });
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> GetMessages(int id) async {
    try {
      isLoading = true;
      notifyListeners();

      final dio = await ApiClient.getClient();
      final response = await dio.get(
        //"http://192.168.100.11:5000/get_sessions_messages/$id",
        //"http://127.0.0.1:5000/get_sessions_messages/$id",
        "https://aichatapp.pythonanywhere.com/get_sessions_messages/$id",

      );

      final res = response.data;
      _sessionId = res["session_id"];
      sessionTitle = res["title"];
      messages = List<Map<String, dynamic>>.from(res["messages"]);
    } catch (e) {
      messages.add({"role": "model", "message": "Error fetching messages"});
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void ResetChat() {
    _sessionId = null;
    messages.clear();
    sessionTitle = null;
    notifyListeners();
  }

  void addLocalMessage(Map<String, dynamic> msg) {
    messages.add(msg);
    notifyListeners();
  }
}
