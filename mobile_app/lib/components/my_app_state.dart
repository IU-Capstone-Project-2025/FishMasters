import 'package:flutter/material.dart';

class MyAppState extends ChangeNotifier {
  // This class can hold the state of the application.
  // For example, you can add properties to manage the current page, user data, etc.
  int _currentPage = 0;

  int get currentPage => _currentPage;

  void changePage(int page) {
    _currentPage = page;
    notifyListeners();
  }
}
