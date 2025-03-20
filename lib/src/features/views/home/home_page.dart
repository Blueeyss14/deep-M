import 'package:deep_m/src/features/viewmodels/bottombar_viemodel.dart';
import 'package:deep_m/src/features/views/pages/playlist_page.dart';
import 'package:deep_m/src/features/views/pages/search_page.dart';
import 'package:deep_m/src/features/views/pages/song_home_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  List<Widget> pages = [SongHomePage(), SearchPage(), PlaylistPage()];

  @override
  Widget build(BuildContext context) {
    final bottomNavItem = Provider.of<BottombarViemodel>(context);
    super.build(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        title: Text("App Name"),
        // leading: Icon(Icons.menu),
        // actions: [
        //   Padding(
        //     padding: const EdgeInsets.symmetric(horizontal: 15),
        //     child: Icon(Icons.search),
        //   ),
        // ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: PageView(
                  controller: bottomNavItem.pageController,
                  children: pages,
                  onPageChanged: (index) {
                    setState(() {
                      bottomNavItem.currentIndex = index;
                    });
                  },
                ),
              ),
            ],
          ),

          /// BOTTOM BAR
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withAlpha(10),
                      Colors.black.withAlpha(1000),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(
                    bottomNavItem.bottomBarItem.length,
                    (i) => Expanded(
                      child: GestureDetector(
                        onTap: () => bottomNavItem.pageIndex(i),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          color: Colors.transparent,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                bottomNavItem.bottomBarItem[i].icon.icon,
                                size: 25,
                              ),
                              Text(
                                bottomNavItem.bottomBarItem[i].title,
                                style: TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
