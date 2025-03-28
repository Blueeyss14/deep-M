import 'dart:ui';

import 'package:deep_m/src/features/viewmodels/bottombar_viemodel.dart';
import 'package:deep_m/src/features/viewmodels/music_provider.dart';
import 'package:deep_m/src/features/views/components/bottom_bar.dart';
import 'package:deep_m/src/shared/components/music_player_bar.dart';
import 'package:deep_m/src/features/views/pages/playlist_page.dart';
import 'package:deep_m/src/features/views/pages/search_page.dart';
import 'package:deep_m/src/features/views/pages/song_home_page.dart';
import 'package:deep_m/src/shared/style/custom_color.dart';
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
    final audioPlayer = Provider.of<MusicProvider>(context);
    super.build(context);
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset("images/nero-deep-M.png", fit: BoxFit.cover),
        Scaffold(
          backgroundColor: Colors.transparent,
          resizeToAvoidBottomInset: false,

          body: SafeArea(
            child: Stack(
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
                    if (audioPlayer.currentChannel.isNotEmpty)
                      if (ModalRoute.of(context)?.isCurrent == true)
                        MusicPlayerBar(),

                    const SizedBox(height: 5),

                    ///BOTTOM BAR
                    BottomBar(),
                  ],
                ),
              ],
            ),
          ),
        ),

        if (ModalRoute.of(context)?.isCurrent == false)
          Center(
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),

                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        CustomColor.musicBar1.withAlpha(10),
                        CustomColor.musicBar2.withAlpha(100),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
            ),
          ),

        if (audioPlayer.isBuffering)
          Center(
            child: SizedBox(
              height: 30,
              width: 30,
              child: CircularProgressIndicator(
                color: CustomColor.white1,
                strokeWidth: 3,
              ),
            ),
          ),
      ],
    );
  }
}
