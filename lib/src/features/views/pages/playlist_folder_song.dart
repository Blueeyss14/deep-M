import 'package:deep_m/src/features/viewmodels/download_song_provider.dart';
import 'package:deep_m/src/features/viewmodels/music_provider.dart';
import 'package:deep_m/src/features/viewmodels/playlist_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PlaylistFolderSong extends StatelessWidget {
  final String playlistName;
  const PlaylistFolderSong({super.key, required this.playlistName});

  @override
  Widget build(BuildContext context) {
    final playlistProvider = Provider.of<PlaylistProvider>(context);
    final downloadSongProvider = Provider.of<DownloadSongProvider>(context);
    final musicProvider = Provider.of<MusicProvider>(context, listen: false);
    final songs = playlistProvider.playlists[playlistName] ?? [];
    return Scaffold(
      appBar: AppBar(title: Text(playlistName), elevation: 0),
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
                padding: const EdgeInsets.all(16),
                itemCount: songs.length,
                itemBuilder: (context, songIndex) {
                  final song = songs[songIndex];
                  final videoId = song['videoId'] ?? '';
                  final downloadStatus =
                      downloadSongProvider.downloadStatus[videoId];
                  final isPlayingThisSong =
                      musicProvider.isPlaying &&
                      musicProvider.currentTitle == song['title'];

                  return Card(
                    margin: EdgeInsets.only(bottom: 12),
                    elevation: 2,
                    child: GestureDetector(
                      onTap: () {
                        musicProvider.startPlaylist(
                          context,
                          playlistName,
                          songIndex,
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Image.network(
                                    song['thumbnail'] ?? '',
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 60,
                                        height: 60,
                                        color: Colors.grey[300],
                                        child: Icon(Icons.music_note),
                                      );
                                    },
                                  ),
                                ),
                                if (isPlayingThisSong)
                                  Container(
                                    width: 60,
                                    height: 60,
                                    color: Colors.black54,
                                    child: Icon(
                                      Icons.play_arrow,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    song['title'] ?? 'Tidak Ada',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color:
                                          isPlayingThisSong
                                              ? Theme.of(context).primaryColor
                                              : null,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    song['channel'] ?? 'Tidak Ada',
                                    style: TextStyle(fontSize: 12),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  // _buildDownloadStatus(
                                  //   context,
                                  //   downloadStatus,
                                  //   videoId,
                                  //   song['title'] ?? 'Tidak Ada',
                                  // ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                playlistProvider.removeSongFromPlaylist(
                                  playlistName,
                                  song,
                                );
                              },
                              icon: Icon(Icons.delete),
                              tooltip: 'Hapus dari playlist',
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
