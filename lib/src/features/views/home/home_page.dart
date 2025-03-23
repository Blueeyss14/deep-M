import 'dart:ui';

import 'package:deep_m/src/features/viewmodels/bottombar_viemodel.dart';
import 'package:deep_m/src/features/views/components/bottom_bar.dart';
import 'package:deep_m/src/features/views/components/music_player_bar.dart';
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
    return Stack(
      children: [
        Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            title: Text("App Name"),
          ),
          body: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child:
                        NotificationListener<OverscrollIndicatorNotification>(
                          onNotification: (
                            OverscrollIndicatorNotification overscroll,
                          ) {
                            overscroll.disallowIndicator();
                            return true;
                          },
                          child: PageView(
                            padEnds: false,
                            controller: bottomNavItem.pageController,
                            children: pages,
                            onPageChanged: (index) {
                              setState(() {
                                bottomNavItem.currentIndex = index;
                              });
                            },
                          ),
                        ),
                  ),
                ],
              ),

              /// BOTTOM BAR && MUSIC PLAYER BAR
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ///MUSIC PLAYER BAR
                  MusicPlayerBar(),

                  ///BOTTOM BAR
                  BottomBar(),
                ],
              ),
            ],
          ),
        ),

        // if (ModalRoute.of(context)?.isCurrent == false)
        // Center(
        //   child: ClipRect(
        //     child: BackdropFilter(
        //       filter: ImageFilter.blur(
        //         sigmaX: ModalRoute.of(context)?.isCurrent == false ? 2 : 0,
        //         sigmaY: ModalRoute.of(context)?.isCurrent == false ? 2 : 0,
        //       ),
        //       child: AnimatedContainer(
        //         height:
        //             ModalRoute.of(context)?.isCurrent == false
        //                 ? MediaQuery.of(context).size.height
        //                 : 0,
        //         width:
        //             ModalRoute.of(context)?.isCurrent == false
        //                 ? MediaQuery.of(context).size.width
        //                 : 0,
        //         duration: Duration(milliseconds: 100),
        //       ),
        //     ),
        //   ),
        // ),
      ],
    );
  }
}
