import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:deep_m/src/features/viewmodels/music_provider.dart';
import 'package:deep_m/src/features/viewmodels/playlist_provider.dart';
import 'package:deep_m/src/features/views/dialog/delete_song_dialog.dart';
import 'package:deep_m/src/shared/components/is_downloaded.dart';
import 'package:deep_m/src/shared/components/music_player_bar.dart';
import 'package:deep_m/src/shared/style/custom_color.dart';
import 'package:deep_m/src/shared/widgets/blur_background.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PlaylistFolderSong extends StatefulWidget {
  final String playlistName;
  const PlaylistFolderSong({super.key, required this.playlistName});

  @override
  State<PlaylistFolderSong> createState() => _PlaylistFolderSongState();
}

class _PlaylistFolderSongState extends State<PlaylistFolderSong> {
  @override
  Widget build(BuildContext context) {
    final playlistProvider = Provider.of<PlaylistProvider>(context);
    final musicProvider = Provider.of<MusicProvider>(context, listen: false);
    final songs = playlistProvider.playlists[widget.playlistName] ?? [];
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset("images/nero-deep-M.png", fit: BoxFit.cover),

        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            foregroundColor: CustomColor.white1,
            surfaceTintColor: Colors.transparent,
            backgroundColor: Colors.transparent,
            title: Text(widget.playlistName),
            elevation: 0,
          ),
          body:
              songs.isEmpty
                  ? Center(
                    child: Text(
                      "No song in this playlist",
                      style: TextStyle(color: CustomColor.white2),
                    ),
                  )
                  : ListView.builder(
                    padding: EdgeInsets.only(top: 15),
                    itemCount: songs.length,
                    itemBuilder: (context, songIndex) {
                      final song = songs[songIndex];
                      final videoId = song['videoId'] ?? '';

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            musicProvider.startPlaylist(
                              context,
                              widget.playlistName,
                              songIndex,
                            );
                          });
                        },
                        child: ClipRect(
                          clipBehavior: Clip.antiAlias,
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 8),

                            child: Padding(
                              padding: EdgeInsets.only(bottom: 8),
                              child: BlurBackground(
                                padding: const EdgeInsets.all(10),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 15,
                                ),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(3),
                                      child: CachedNetworkImage(
                                        imageUrl: song['thumbnail'] ?? '',
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
                                            song['title'] ?? '',
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: CustomColor.white1,
                                            ),
                                          ),
                                          Text(
                                            song['channel'] ?? '',
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: CustomColor.white2,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    isDownloaded(context, videoId),

                                    GestureDetector(
                                      onTap: () {
                                        deleteSongDialog(
                                          context,
                                          widget.playlistName,
                                          song,
                                          playlistProvider,
                                        );
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 5),
                                        child: Icon(
                                          Icons.delete,
                                          color: CustomColor.white1,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
        ),

        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ///MUSIC PLAYER BAR
            if (musicProvider.currentChannel.isNotEmpty)
              if (ModalRoute.of(context)?.isCurrent == true) MusicPlayerBar(),

            const SizedBox(height: 50),
          ],
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
      ],
    );
  }
}
