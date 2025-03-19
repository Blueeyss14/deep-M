import 'package:flutter/material.dart';

class BottomBarModel {
  Icon icon;
  String title;

  BottomBarModel(this.icon, this.title);

  static List<BottomBarModel> bottomBar() {
    List<Map<String, dynamic>> datas = [
      {"icon": Icons.home, "title": "Home"},
      {"icon": Icons.search, "title": "Search"},
      {"icon": Icons.playlist_add, "title": "Playlist"},
    ];

    return datas
        .map((data) => BottomBarModel(Icon(data["icon"]), data["title"]))
        .toList();
  }
}
