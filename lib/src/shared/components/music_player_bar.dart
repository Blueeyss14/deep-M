import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:deep_m/src/features/viewmodels/music_provider.dart';
import 'package:deep_m/src/features/views/utils/music_bottom_sheet.dart';
import 'package:deep_m/src/shared/style/custom_color.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MusicPlayerBar extends StatefulWidget {
  const MusicPlayerBar({super.key});

  @override
  State<MusicPlayerBar> createState() => _MusicPlayerBarState();
}

class _MusicPlayerBarState extends State<MusicPlayerBar> {
  @override
  Widget build(BuildContext context) {
    final audioPlayer = Provider.of<MusicProvider>(context);

    return GestureDetector(
      onTap: () {
        setState(() {
          musicBottomSheet(context);
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: ClipRect(
            clipBehavior: Clip.antiAlias,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 12),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      CustomColor.musicBar1.withAlpha(100),
                      CustomColor.musicBar2.withAlpha(150),
                      CustomColor.musicBar3.withAlpha(150),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),

                clipBehavior: Clip.antiAlias,
                width: double.infinity,
                child: Column(
                  children: [
                    StreamBuilder(
                      stream: audioPlayer.audioPlayer.positionStream,
                      builder: (context, positionSnapshot) {
                        final position = positionSnapshot.data ?? Duration.zero;

                        return StreamBuilder(
                          stream: audioPlayer.audioPlayer.durationStream,
                          builder: (context, durationSnapshot) {
                            final duration =
                                durationSnapshot.data ?? Duration.zero;

                            if (audioPlayer.isBuffering) {
                              return const CircularProgressIndicator();
                            } else {
                              return Column(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    alignment: Alignment.topLeft,
                                    child: LinearProgressIndicator(
                                      value:
                                          duration.inSeconds > 0
                                              ? position.inSeconds /
                                                  duration.inSeconds
                                              : 0,
                                      backgroundColor: Colors.grey[300],
                                      valueColor:
                                          const AlwaysStoppedAnimation<Color>(
                                            Colors.red,
                                          ),
                                      minHeight: 2,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 5,
                                    ),
                                    child: Row(
                                      children: [
                                        if (audioPlayer
                                            .currentThumbnail
                                            .isEmpty)
                                          const Icon(Icons.music_note, size: 40)
                                        else
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              3,
                                            ),
                                            child: CachedNetworkImage(
                                              imageUrl:
                                                  audioPlayer.currentThumbnail,
                                              width: 40,
                                              height: 40,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                audioPlayer.currentTitle,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: CustomColor.white1,
                                                ),

                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Text(
                                                audioPlayer.isPlayingOffline
                                                    ? "🎵 ${audioPlayer.currentChannel} (offline)"
                                                    : audioPlayer
                                                        .currentChannel,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: CustomColor.white2,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Control buttons
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            SizedBox(width: 15),
                                            _buildRepeatModeButton(audioPlayer),

                                            // if (audioPlayer
                                            //     .isPlayingFromPlaylist)
                                            //   IconButton(
                                            //     icon: Icon(
                                            //       Icons.skip_previous,
                                            //       size: 20,
                                            //     ),
                                            //     onPressed: () {
                                            //       audioPlayer.playPreviousSong(
                                            //         context,
                                            //       );
                                            //     },
                                            //     tooltip: 'Lagu sebelumnya',
                                            //     padding: EdgeInsets.zero,
                                            //     constraints: BoxConstraints(
                                            //       minWidth: 32,
                                            //       minHeight: 32,
                                            //     ),
                                            //   ),
                                            if (audioPlayer.isPlaying)
                                              IconButton(
                                                icon: Icon(Icons.pause),
                                                onPressed: () {
                                                  audioPlayer.pauseAudio();
                                                },
                                                tooltip: 'Pause',
                                                padding: EdgeInsets.zero,
                                                constraints: BoxConstraints(
                                                  minWidth: 40,
                                                  minHeight: 40,
                                                ),
                                                color: CustomColor.white1,
                                              )
                                            else
                                              IconButton(
                                                icon: Icon(Icons.play_arrow),
                                                onPressed: () {
                                                  audioPlayer.audioPlayer
                                                      .play();
                                                },
                                                tooltip: 'Play',
                                                padding: EdgeInsets.zero,
                                                constraints: BoxConstraints(
                                                  minWidth: 40,
                                                  minHeight: 40,
                                                ),
                                                color: CustomColor.white1,
                                              ),

                                            // if (audioPlayer
                                            //     .isPlayingFromPlaylist)
                                            //   IconButton(
                                            //     icon: Icon(
                                            //       Icons.skip_next,
                                            //       size: 20,
                                            //     ),
                                            //     onPressed: () {
                                            //       audioPlayer.playNextSong(
                                            //         context,
                                            //       );
                                            //     },
                                            //     tooltip: 'Lagu berikutnya',
                                            //     padding: EdgeInsets.zero,
                                            //     constraints: BoxConstraints(
                                            //       minWidth: 32,
                                            //       minHeight: 32,
                                            //     ),
                                            //   ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            }
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRepeatModeButton(MusicProvider audioPlayer) {
    // Cek apakah sedang memutar dari playlist
    final bool isPlaylist = audioPlayer.isPlayingFromPlaylist;

    IconData iconData;
    Color iconColor;
    String tooltip;

    switch (audioPlayer.repeatMode) {
      case RepeatMode.none:
        iconData = Icons.repeat;
        iconColor = Colors.grey;
        tooltip = 'Sekali saja';
        break;
      case RepeatMode.playlist:
        iconData = Icons.repeat;
        iconColor = isPlaylist ? Colors.black : Colors.grey[400]!;
        tooltip =
            isPlaylist
                ? 'Putar semua lagu di playlist'
                : 'Mode tidak tersedia (tidak dalam playlist)';
        break;
      case RepeatMode.single:
        iconData = Icons.repeat_one;
        iconColor = Colors.black;
        tooltip = 'Ulang lagu ini';
        break;
    }

    return GestureDetector(
      onTap: () {
        if (audioPlayer.repeatMode == RepeatMode.none && !isPlaylist) {
          // Toggle sekali untuk ke playlist
          audioPlayer.toggleLoopMode();
          // Toggle lagi untuk langsung ke single guli guli watcha
          audioPlayer.toggleLoopMode();
        } else {
          audioPlayer.toggleLoopMode();
        }
      },
      child: Tooltip(
        message: tooltip,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Icon(iconData, color: iconColor, size: 20),
        ),
      ),
    );
  }
}
