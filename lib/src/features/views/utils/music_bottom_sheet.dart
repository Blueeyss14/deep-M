import 'package:cached_network_image/cached_network_image.dart';
import 'package:deep_m/src/features/viewmodels/music_provider.dart';
import 'package:deep_m/src/shared/current_song_text.dart';
import 'package:deep_m/src/shared/components/music_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void musicBottomSheet(BuildContext context) {
  final musicProvider = Provider.of<MusicProvider>(context, listen: false);

  showModalBottomSheet(
    clipBehavior: Clip.antiAlias,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppBar(
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    title:
                        musicProvider.isPlayingFromPlaylist
                            ? Text(
                              "Playlist: ${musicProvider.currentPlaylistName}",
                              style: TextStyle(fontSize: 16),
                            )
                            : null,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child:
                                  musicProvider.currentThumbnail.isNotEmpty
                                      ? CachedNetworkImage(
                                        imageUrl:
                                            musicProvider.currentThumbnail,
                                        width: 300,
                                        height: 300,
                                        fit: BoxFit.cover,
                                      )
                                      : Container(
                                        width: 300,
                                        height: 300,
                                        color: Colors.grey[300],
                                        child: Icon(Icons.music_note, size: 80),
                                      ),
                            ),
                            if (musicProvider.isPlayingOffline)
                              Positioned(
                                right: 15,
                                bottom: 15,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.offline_bolt,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        "Offline",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          musicProvider.currentTitle,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          musicProvider.currentChannel.isNotEmpty
                              ? musicProvider.currentChannel
                              : '',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Music slider
                        MusicSlider(),
                        CurrentSongText(),

                        // Player controls
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
                                        ? Colors.black
                                        : Colors.grey[400],
                              ),
                              onPressed:
                                  musicProvider.isPlayingFromPlaylist
                                      ? () {
                                        musicProvider.playPreviousSong(context);
                                      }
                                      : null,
                            ),

                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.amber,
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: Icon(
                                  musicProvider.isPlaying
                                      ? Icons.pause
                                      : Icons.play_arrow,
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
                                        ? Colors.black
                                        : Colors.grey[400],
                              ),
                              onPressed:
                                  musicProvider.isPlayingFromPlaylist
                                      ? () {
                                        musicProvider.playNextSong(context);
                                      }
                                      : null,
                            ),

                            SizedBox(width: 32),
                          ],
                        ),

                        const SizedBox(height: 20),

                        if (musicProvider.currentDescription.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Deskripsi:",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                musicProvider.currentDescription,
                                style: TextStyle(fontSize: 13),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
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
