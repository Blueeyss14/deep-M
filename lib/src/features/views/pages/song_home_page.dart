import 'package:cached_network_image/cached_network_image.dart';
import 'package:deep_m/src/features/viewmodels/music_provider.dart';
import 'package:deep_m/src/shared/widgets/blur_background.dart';
import 'package:deep_m/src/shared/components/current_song_duration.dart';
import 'package:deep_m/src/shared/components/music_slider.dart';
import 'package:deep_m/src/shared/style/custom_color.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SongHomePage extends StatefulWidget {
  const SongHomePage({super.key});

  @override
  State<SongHomePage> createState() => _SongHomePageState();
}

class _SongHomePageState extends State<SongHomePage>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final musicProvider = Provider.of<MusicProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height / 4 - 50),
              Row(
                children: [
                  ///THUMBNAIL------
                  BlurBackground(
                    borderRadius: BorderRadius.circular(8),
                    padding: const EdgeInsets.all(12),
                    height: 70,
                    width: 70,
                    child:
                        musicProvider.currentThumbnail.isNotEmpty
                            ? ClipRRect(
                              borderRadius: BorderRadius.circular(3),
                              child: CachedNetworkImage(
                                imageUrl: musicProvider.currentThumbnail,
                                fit: BoxFit.cover,
                              ),
                            )
                            : const SizedBox(),
                  ),

                  const SizedBox(width: 15),
                  Expanded(
                    child: BlurBackground(
                      borderRadius: BorderRadius.circular(8),
                      padding: const EdgeInsets.all(15),
                      height: 70,
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

              BlurBackground(
                alignment: Alignment.center,
                margin: const EdgeInsets.symmetric(vertical: 15),
                width: double.infinity,
                height: 200,
                child:
                    (musicProvider.currentTitle.isNotEmpty &&
                                musicProvider.isPlayingOffline ||
                            musicProvider.currentChannel.isNotEmpty &&
                                musicProvider.isPlayingOffline)
                        ? Stack(
                          children: [
                            Positioned.fill(
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          color: Colors.black.withAlpha(20),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.offline_bolt,
                                              color: CustomColor.white1,
                                              size: 14,
                                            ),
                                            const SizedBox(width: 5),
                                            Text(
                                              "Offline",
                                              style: TextStyle(
                                                color: CustomColor.white2,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        Icons.check_circle,
                                        size: 16,
                                        color: Colors.green,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Center(
                              child: Text(
                                "You're Playing Offline Song",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: CustomColor.white2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        )
                        : !musicProvider.isPlayingOffline &&
                            musicProvider.currentTitle.isNotEmpty
                        ? Center(
                          child: Text(
                            "You're Playing Online Song",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: CustomColor.white2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        : Text(
                          "No Song Played",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: CustomColor.white2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
              ),

              BlurBackground(
                padding: const EdgeInsets.symmetric(vertical: 10),
                width: double.infinity,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
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
                          child:
                              CurrentSongDuration.duration.inSeconds != 0
                                  ? IconButton(
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
                                  )
                                  : Icon(
                                    Icons.play_arrow,
                                    color: CustomColor.blackSheet,
                                    size: 32,
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
                      ],
                    ),
                    const SizedBox(height: 5),
                    MusicSlider(),
                    CurrentSongDuration(),
                  ],
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height / 4),
            ],
          ),
        ),
      ),
    );
  }
}
