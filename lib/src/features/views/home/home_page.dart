import 'package:deep_m/src/features/model/UI/bottomBar_model.dart';
import 'package:deep_m/src/features/views/pages/playlist_page.dart';
import 'package:deep_m/src/features/views/pages/search_page.dart';
import 'package:deep_m/src/features/views/pages/song_home_page.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  List<Widget> pages = [SongHomePage(), SearchPage(), PlaylistPage()];
  List<BottomBarModel> bottomBarItem = BottomBarModel.bottomBar();
  int currentIndex = 0;
  PageController pageController = PageController();

  void pageIndex(int index) {
    setState(() {
      currentIndex = index;
    });
    pageController.animateToPage(
      currentIndex,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
                    setState(() {
                      currentIndex = index;
                    });
                  },
                ),
              ),
            ],
          ),

          /// BOTTOM BAR
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 30,
              width: double.infinity,
              color: Colors.green,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(
                  bottomBarItem.length,
                  (i) => GestureDetector(
                    onTap: () => pageIndex(i),
                    child: Text(bottomBarItem[i].title),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
