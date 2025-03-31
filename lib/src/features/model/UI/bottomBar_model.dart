import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

class BottomBarModel {
  Icon icon;
  String title;

  BottomBarModel(this.icon, this.title);

  static List<BottomBarModel> bottomBar() {
    List<Map<String, dynamic>> datas = [
      {"icon": LineAwesomeIcons.home_solid, "title": "Home"},
      {"icon": LineAwesomeIcons.search_solid, "title": "Search"},
      {"icon": LineAwesomeIcons.music_solid, "title": "Playlist"},
    ];

    return datas
        .map((data) => BottomBarModel(Icon(data["icon"]), data["title"]))
        .toList();
  }
}
