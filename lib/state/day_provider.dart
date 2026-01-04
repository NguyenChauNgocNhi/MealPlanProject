import 'package:flutter/material.dart';

class DayProvider extends ChangeNotifier {
  DateTime _selectedDay = DateTime.now();

  DateTime get selectedDay => _selectedDay;

  void setDay(DateTime day) {
    _selectedDay = day;
    notifyListeners();
  }
}
