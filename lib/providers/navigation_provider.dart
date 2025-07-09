import 'package:flutter/material.dart';

class NavigationProvider extends ChangeNotifier {
  int _currentIndex = 0;
  int? _previousIndex;

  int get currentIndex => _currentIndex;

  int? get previousIndex => _previousIndex;

  void setIndex(int index) {
    if (index != _currentIndex) {
      _previousIndex = _currentIndex;
      _currentIndex = index;
      notifyListeners();
    }
  }

  void goBack() {
    if (_previousIndex != null) {
      final temp = _currentIndex;
      _currentIndex = _previousIndex!;
      _previousIndex = temp;
      notifyListeners();
    }
  }
}
