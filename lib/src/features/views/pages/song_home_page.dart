import 'package:cached_network_image/cached_network_image.dart';
import 'package:deep_m/src/features/viewmodels/music_provider.dart';
import 'package:deep_m/src/shared/components/current_song_duration.dart';
import 'package:deep_m/src/shared/components/is_downloaded.dart';
import 'package:deep_m/src/shared/components/music_slider.dart';
import 'package:deep_m/src/shared/style/custom_color.dart';
import 'package:deep_m/src/shared/widgets/build_repeat_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SongHomePage extends StatefulWidget {
  const SongHomePage({super.key});

  @override
  State<SongHomePage> createState() => _SongHomePageState();
}

class _SongHomePageState extends State<SongHomePage> {
  @override
  Widget build(BuildContext context) {
    final musicProvider = Provider.of<MusicProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                children: [
                  ///THUMBNAIL------
                  Container(
                    height: 70,
                    width: 70,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        width: 0.5,
                        color: CustomColor.white2.withAlpha(100),
                      ),
                      gradient: LinearGradient(
                        colors: [
                          CustomColor.musicBar1.withAlpha(50),
                          CustomColor.musicBar2.withAlpha(70),
                          CustomColor.musicBar3.withAlpha(80),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                    child:
                        ///IMAGE
                        musicProvider.currentThumbnail.isNotEmpty
                            ? Padding(
                              padding: const EdgeInsets.all(8),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(3),
                                child: CachedNetworkImage(
                                  imageUrl: musicProvider.currentThumbnail,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )
                            : const SizedBox(),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      height: 70,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          width: 0.5,
                          color: CustomColor.white2.withAlpha(100),
                        ),
                        gradient: LinearGradient(
                          colors: [
                            CustomColor.musicBar1.withAlpha(50),
                            CustomColor.musicBar2.withAlpha(70),
                            CustomColor.musicBar3.withAlpha(80),
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (musicProvider.currentTitle.isNotEmpty)
                            Text(
                              musicProvider.currentTitle,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: CustomColor.white1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          if (musicProvider.currentChannel.isNotEmpty)
                            Text(
                              musicProvider.currentChannel,
                              style: TextStyle(
                                fontSize: 12,
                                color: CustomColor.white2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              /// ini-------------------------------------------COVER--------------------------------------
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    width: 0.5,
                    color: CustomColor.white2.withAlpha(100),
                  ),
                  gradient: LinearGradient(
                    colors: [
                      CustomColor.musicBar1.withAlpha(50),
                      CustomColor.musicBar2.withAlpha(70),
                      CustomColor.musicBar3.withAlpha(80),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    width: 0.5,
                    color: CustomColor.white2.withAlpha(100),
                  ),
                  gradient: LinearGradient(
                    colors: [
                      CustomColor.musicBar1.withAlpha(50),
                      CustomColor.musicBar2.withAlpha(70),
                      CustomColor.musicBar3.withAlpha(80),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // buildRepeatModeButton(context, musicProvider, setState),
                        IconButton(
                          icon: Icon(
                            Icons.skip_previous,
                            size: 28,
                            color:
                                musicProvider.isPlayingFromPlaylist
                                    ? CustomColor.white1
                                    : CustomColor.white3,
                          ),
                          onPressed: () {
                            if (musicProvider.isPlayingFromPlaylist) {
                              setState(() {
                                musicProvider.playNextSong(context);
                              });
                            }
                          },
                        ),

                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: CustomColor.white1,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: Icon(
                              musicProvider.isPlaying
                                  ? Icons.pause
                                  : Icons.play_arrow,
                              color: CustomColor.blackSheet,
                              size: 32,
                            ),
                            onPressed: () {
                              if (musicProvider.isPlaying) {
                                musicProvider.pauseAudio();
                              } else {
                                musicProvider.audioPlayer.play();
                              }
                              setState(() {});
                            },
                          ),
                        ),

                        IconButton(
                          icon: Icon(
                            Icons.skip_next,
                            size: 28,
                            color:
                                musicProvider.isPlayingFromPlaylist
                                    ? CustomColor.white1
                                    : CustomColor.white3,
                          ),
                          onPressed: () {
                            if (musicProvider.isPlayingFromPlaylist) {
                              setState(() {
                                musicProvider.playNextSong(context);
                              });
                            }
                          },
                        ),

                        // if (musicProvider.isPlayingOffline)
                        //   GestureDetector(
                        //     onTap: addPlaylist,
                        //     child: Transform.scale(
                        //       scale: 1.5,
                        //       child: Padding(
                        //         padding: const EdgeInsets.all(10),
                        //         child: isDownloaded(context, videoId),
                        //       ),
                        //     ),
                        //   )
                        // else
                        //   GestureDetector(
                        //     onTap: addPlaylist,
                        //     child: Icon(
                        //       Icons.add_circle_outline,
                        //       size: 26,
                        //       color: CustomColor.white2,
                        //     ),
                        //   ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    MusicSlider(),
                    CurrentSongDuration(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
