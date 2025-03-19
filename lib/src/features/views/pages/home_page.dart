import 'package:deep_m/src/features/views/pages/playlist_page.dart';
import 'package:deep_m/src/features/views/pages/search_page.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Widget> pages = [HomePage(), SearchPage(), PlaylistPage()];

  @override
  void initState() {
    super.initState();
    pages[0];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(children: [PageView(children: pages)]),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 30,
              width: double.infinity,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}
