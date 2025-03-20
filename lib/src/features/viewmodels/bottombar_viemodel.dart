import 'package:deep_m/src/features/model/UI/bottombar_model.dart';
import 'package:flutter/material.dart';

class BottombarViemodel extends ChangeNotifier {
  int currentIndex = 0;
  PageController pageController = PageController();
  List<BottomBarModel> bottomBarItem = BottomBarModel.bottomBar();

  void pageIndex(int index) {
    currentIndex = index;
    pageController.animateToPage(
      currentIndex,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    notifyListeners();
  }

  @override
  void dispose() {
    pageController.dispose;
    super.dispose();
  }
}
