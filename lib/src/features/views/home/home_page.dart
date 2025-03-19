import 'package:deep_m/src/features/views/pages/playlist_page.dart';
import 'package:deep_m/src/features/views/pages/search_page.dart';
import 'package:deep_m/src/features/views/pages/song_home_page.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Widget> pages = [SongHomePage(), SearchPage(), PlaylistPage()];

  int pageIndex = 0;

  PageController pageController = PageController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: PageView(
                  controller: pageController,
                  children: pages,
                  onPageChanged: (index) {
                    pageIndex = index;
                  },
                ),
              ),
            ],
          ),
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
