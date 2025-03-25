import 'package:deep_m/src/features/viewmodels/download_song_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:deep_m/src/features/viewmodels/music_provider.dart';
import 'package:deep_m/src/features/viewmodels/playlist_provider.dart';

class PlaylistPage extends StatefulWidget {
  const PlaylistPage({super.key});

  @override
  State<PlaylistPage> createState() => _PlaylistPageState();
}

class _PlaylistPageState extends State<PlaylistPage> {
  @override
  void initState() {
    super.initState();
    // Initialize providers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final playlistProvider = Provider.of<PlaylistProvider>(
        context,
        listen: false,
      );
      final downloadSongProvider = Provider.of<DownloadSongProvider>(
        context,
        listen: false,
      );

      playlistProvider.initDownloadSongProvider(context);
      downloadSongProvider.loadDownloadStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final playlistProvider = Provider.of<PlaylistProvider>(context);
    final downloadSongProvider = Provider.of<DownloadSongProvider>(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            playlistProvider.playlists.isNotEmpty
                ? ListView.builder(
                  itemCount: playlistProvider.playlists.length,
                  itemBuilder: (context, index) {
                    String playlistName = playlistProvider.playlists.keys
                        .elementAt(index);
                    List<Map<String, String>> songs =
                        playlistProvider.playlists[playlistName]!;

                    return ExpansionTile(
                      title: Text(playlistName),
                      children:
                          songs.map((song) {
                            final videoId = song['videoId'] ?? '';
                            final downloadStatus =
                                downloadSongProvider.downloadStatus[videoId];

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: GestureDetector(
                                onTap: () {
                                  final musicProvider =
                                      Provider.of<MusicProvider>(
                                        context,
                                        listen: false,
                                      );
                                  musicProvider.playAudio(
                                    context,
                                    song['videoId'] ?? '',
                                    song['title'] ?? 'Tidak Ada',
                                    song['thumbnail'] ?? '',
                                    song['channel'] ?? 'Tidak Ada',
                                    song['description'] ?? 'Tidak Ada',
                                  );
                                },
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(3),
                                      child: Image.network(
                                        song['thumbnail'] ?? '',
                                        width: 48,
                                        height: 48,
                                        fit: BoxFit.cover,
                                        errorBuilder: (
                                          context,
                                          error,
                                          stackTrace,
                                        ) {
                                          return Container(
                                            width: 48,
                                            height: 48,
                                            color: Colors.grey,
                                            child: Icon(Icons.music_note),
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  song['title'] ?? 'Tidak Ada',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  song['channel'] ??
                                                      'Tidak Ada',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                _buildDownloadStatus(
                                                  downloadStatus,
                                                ),
                                              ],
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              IconButton(
                                                onPressed: () {
                                                  playlistProvider
                                                      .removeSongFromPlaylist(
                                                        playlistName,
                                                        song,
                                                      );
                                                },
                                                icon: Icon(Icons.delete),
                                                tooltip: 'Remove from playlist',
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                    );
                  },
                )
                : Center(child: Text("No Playlist")),
      ),
    );
  }

  Widget _buildDownloadStatus(bool? status) {
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
          Icon(Icons.cloud_download, size: 14, color: Colors.grey),
          SizedBox(width: 4),
          Text(
            "Menunggu untuk didownload",
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      );
    }
  }
}
