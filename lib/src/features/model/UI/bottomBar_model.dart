import 'package:flutter/material.dart';

class BottomBarModel {
  Icon icon;
  String title;

  BottomBarModel(this.icon, this.title);

  static List<BottomBarModel> bottomBar() {
    return [
      BottomBarModel(Icon(Icons.home), "Home"),
      BottomBarModel(Icon(Icons.home), "Search"),
      BottomBarModel(Icon(Icons.home), "Playlist"),
    ];
  }
}
