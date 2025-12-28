import 'package:flutter/cupertino.dart';
import '../Cookies/api_client.dart';

class SelectionProvider extends ChangeNotifier {
  dynamic selected_msg_id;
  int? selected_session_id;

  bool get hasMessageSelection => selected_msg_id != null;
  bool get hasSessionSelection => selected_session_id != null;

  void deleteLocalMessage(int id,List messages) {
    messages.removeWhere((msg) => msg["id"] == id);
    notifyListeners(); // triggers UI rebuild
  }
  Future<void> deleteMsg(int id, List messages,VoidCallback onUpdate) async {
    try {
      final dio = await ApiClient.getClient(); // Dio with CookieManager
      final response = await dio.get(
        //"http://192.168.100.11:5000/delete_msg/$id",
        //  "http://127.0.0.1:5000/delete_msg/$id"
        "https://aichatapp.pythonanywhere.com/delete_msg/$id",
      );
      if (response.statusCode == 200) {
        messages.removeWhere((msg) => msg["id"] == id);
        selected_msg_id = null;
        onUpdate(); // trigger ChatProvider UI update
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error deleting message: $e");
    }
  }

  Future<void> deleteSession(int id, List sessions) async {
    try {
      final dio = await ApiClient.getClient();
      final response = await dio.get(
        //"http://192.168.100.11:5000/delete_session/$id",
        //  "http://127.0.0.1:5000/delete_session/$id"
        "https://aichatapp.pythonanywhere.com/delete_session/$id",

      );
      if (response.statusCode == 200) {
        sessions.removeWhere((session) => session['id'] == id);
        selected_session_id = null;
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error deleting session: $e");
    }
  }

  void selectMessage(int id) {
    selected_msg_id = id;
    notifyListeners();
  }

  void selectSession(int id) {
    selected_session_id = id;
    notifyListeners();
  }

  void clearMessageSelection() {
    selected_msg_id = null;
    notifyListeners();
  }

  void clearSessionSelection() {
    selected_session_id = null;
    notifyListeners();
  }

  void clearAllSelections() {
    selected_msg_id = null;
    selected_session_id = null;
    notifyListeners();
  }
}
