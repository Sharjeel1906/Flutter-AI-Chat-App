import 'dart:async';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class InternetProvider extends ChangeNotifier {
  bool _isConnected = false;
  bool get isConnected => _isConnected;

  late StreamSubscription<InternetConnectionStatus> _subscription;

  InternetProvider() {
    _init();
  }

  void _init() async {
    _isConnected = await InternetConnectionChecker().hasConnection;
    notifyListeners();

    _subscription =
        InternetConnectionChecker().onStatusChange.listen((status) {
          _isConnected = status == InternetConnectionStatus.connected;
          notifyListeners();
        });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
