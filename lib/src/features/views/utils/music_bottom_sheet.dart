import 'package:cached_network_image/cached_network_image.dart';
import 'package:deep_m/src/features/viewmodels/music_provider.dart';
import 'package:deep_m/src/features/viewmodels/playlist_provider.dart';
import 'package:deep_m/src/shared/components/is_downloaded.dart';
import 'package:deep_m/src/shared/current_song_duration.dart';
import 'package:deep_m/src/shared/components/music_slider.dart';
import 'package:deep_m/src/shared/style/custom_color.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void musicBottomSheet(BuildContext context) {
  final musicProvider = Provider.of<MusicProvider>(context, listen: false);
  final playlistProvider = Provider.of<PlaylistProvider>(
    context,
    listen: false,
  );

  String? playlistName = musicProvider.currentPlaylistName;
  int? songIndex = musicProvider.currentSongIndex;

  final songs = playlistProvider.playlists[playlistName] ?? [];
  final song =
      (songIndex >= 0 && songIndex < songs.length) ? songs[songIndex] : null;
  final videoId = song != null ? song['videoId'] ?? '' : '';

  showModalBottomSheet(
    backgroundColor: CustomColor.blackSheet,
    barrierColor: Colors.transparent,
    clipBehavior: Clip.antiAlias,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    context: context,
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ///Dialog dragger yang putih putih itu apalah namanya
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                width: 30,
                height: 4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color: CustomColor.white3,
                ),
              ),
            ),
            StatefulBuilder(
              builder: (context, setState) {
                return Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.8,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 15,
                          ),
                          child: Container(
                            clipBehavior: Clip.antiAlias,
                            height: 250,
                            width: 300,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: CustomColor.white3,
                            ),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                CachedNetworkImage(
                                  imageUrl: musicProvider.currentThumbnail,
                                  fit: BoxFit.cover,
                                ),
                                if (musicProvider.isPlayingOffline)
                                  Container(
                                    padding: const EdgeInsets.only(
                                      bottom: 40,
                                      right: 10,
                                    ),
                                    alignment: Alignment.bottomRight,
                                    height: 10,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withAlpha(70),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.offline_bolt,
                                            color: CustomColor.white1,
                                            size: 16,
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            "Offline",
                                            style: TextStyle(
                                              color: CustomColor.white1,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        Text(
                          musicProvider.currentTitle,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: CustomColor.white1,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          textAlign: TextAlign.center,
                          musicProvider.currentChannel.isNotEmpty
                              ? musicProvider.currentChannel
                              : '',
                          style: TextStyle(
                            fontSize: 14,
                            color: CustomColor.white2,
                          ),
                        ),
                        const SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildRepeatModeButton(
                              context,
                              musicProvider,
                              setState,
                            ),

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
                              width: 60,
                              height: 60,
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

                            if (musicProvider.isPlayingOffline)
                              Transform.scale(
                                scale: 1.5,
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: isDownloaded(context, videoId),
                                ),
                              )
                            else
                              GestureDetector(
                                onTap: () {
                                  setState(() {});
                                },
                                child: Icon(
                                  Icons.add_circle_outline,
                                  size: 26,
                                  color: CustomColor.white2,
                                ),
                              ),
                          ],
                        ),
                        CurrentSongDuration(),
                        MusicSlider(),
                        if (musicProvider.currentDescription.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Text(
                              musicProvider.currentDescription,
                              style: TextStyle(
                                fontSize: 13,
                                color: CustomColor.white2,
                              ),
                            ),
                          ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      );
    },
  );
}

Widget _buildRepeatModeButton(
  BuildContext context,
  MusicProvider musicProvider,
  StateSetter setState,
) {
  final bool isPlaylist = musicProvider.isPlayingFromPlaylist;

  IconData iconData;
  Color iconColor;
  String tooltip;

  switch (musicProvider.repeatMode) {
    case RepeatMode.none:
      iconData = Icons.repeat;
      iconColor = CustomColor.white3;
      tooltip = 'Play once';
      break;
    case RepeatMode.playlist:
      iconData = Icons.repeat;
      iconColor = isPlaylist ? CustomColor.white1 : CustomColor.white3;
      tooltip = isPlaylist ? 'Play all song' : '';
      break;
    case RepeatMode.single:
      iconData = Icons.repeat_one;
      iconColor = CustomColor.white1;
      tooltip = 'Repeat';
      break;
  }

  return IconButton(
    icon: Icon(iconData, color: iconColor, size: 24),
    tooltip: tooltip,
    onPressed: () {
      if (musicProvider.repeatMode == RepeatMode.none && !isPlaylist) {
        musicProvider.toggleLoopMode();
        musicProvider.toggleLoopMode();
      } else {
        musicProvider.toggleLoopMode();
      }
      setState(() {});
    },
  );
}
