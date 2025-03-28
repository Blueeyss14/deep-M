import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:deep_m/src/features/viewmodels/download_song_provider.dart';
import 'package:deep_m/src/features/viewmodels/music_provider.dart';
import 'package:deep_m/src/features/viewmodels/playlist_provider.dart';
import 'package:deep_m/src/features/views/dialog/delete_song_dialog.dart';
import 'package:deep_m/src/shared/components/music_player_bar.dart';
import 'package:deep_m/src/shared/style/custom_color.dart';
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
    final downloadSongProvider = Provider.of<DownloadSongProvider>(context);
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.music_note, size: 80, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          "Playlist ini kosong",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )
                  : ListView.builder(
                    padding: EdgeInsets.only(top: 15),
                    itemCount: songs.length,
                    itemBuilder: (context, songIndex) {
                      final song = songs[songIndex];
                      final videoId = song['videoId'] ?? '';
                      final downloadStatus =
                          downloadSongProvider.downloadStatus[videoId];

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
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 15,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
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
                                    if (downloadStatus == true)
                                      Icon(
                                        Icons.check_circle,
                                        size: 16,
                                        color: Colors.green,
                                      )
                                    else
                                      SizedBox(
                                        width: 10,
                                        height: 10,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: CustomColor.white1,
                                        ),
                                      ),
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
