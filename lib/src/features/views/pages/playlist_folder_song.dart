import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:deep_m/src/features/viewmodels/playlist_provider.dart';
import 'package:deep_m/src/features/views/dialog/delete_playlist_dialog.dart';
import 'package:deep_m/src/shared/style/custom_color.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PlaylistFolderSong extends StatelessWidget {
  final String playlistName;
  const PlaylistFolderSong({super.key, required this.playlistName});

  @override
  Widget build(BuildContext context) {
    final playlistProvider = Provider.of<PlaylistProvider>(context);
    // final downloadSongProvider = Provider.of<DownloadSongProvider>(context);
    // final musicProvider = Provider.of<MusicProvider>(context, listen: false);
    final songs = playlistProvider.playlists[playlistName] ?? [];
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
            title: Text(playlistName),
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
                    padding: EdgeInsets.zero,
                    itemCount: songs.length,
                    itemBuilder: (context, songIndex) {
                      final song = songs[songIndex];
                      // final videoId = song['videoId'] ?? '';
                      // final downloadStatus =
                      //     downloadSongProvider.downloadStatus[videoId];
                      // final isPlayingThisSong =
                      //     musicProvider.isPlaying &&
                      //     musicProvider.currentTitle == song['title'];

                      return ClipRect(
                        clipBehavior: Clip.antiAlias,
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 8),

                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 5),
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
                                  GestureDetector(
                                    onTap: () {
                                      deletePlaylistDialog(
                                        context,
                                        playlistName,
                                        song,
                                        playlistProvider,
                                      );

                                      // playlistProvider.removeSongFromPlaylist(
                                      //   playlistName,
                                      //   song,
                                      // );
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
                      );
                    },
                  ),
        ),
      ],
    );
  }

  Widget _buildDownloadStatus(
    BuildContext context,
    bool? status,
    String videoId,
    String title,
  ) {
    if (status == true) {
      return Row(
        children: [
          Icon(Icons.check_circle, size: 14, color: Colors.green),
          SizedBox(width: 4),
          Text(
            "Terdownload",
            style: TextStyle(fontSize: 12, color: Colors.green),
          ),
        ],
      );
    } else if (status == false) {
      return Row(
        children: [
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 4),
          Text("Sedang mendownload...", style: TextStyle(fontSize: 12)),
        ],
      );
    } else {
      return Row(
        children: [
          Icon(Icons.cloud_download, size: 14, color: Colors.orange),
          SizedBox(width: 4),
          Text(
            "Menunggu download",
            style: TextStyle(fontSize: 12, color: Colors.orange),
          ),
        ],
      );
    }
  }
}
