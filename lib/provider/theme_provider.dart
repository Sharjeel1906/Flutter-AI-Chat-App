import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier{
  bool isdark = false;

  void updatetheme(bool value){
    isdark = value;
    notifyListeners();
  }
}