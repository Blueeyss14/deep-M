import 'package:deep_m/src/features/viewmodels/download_song_provider.dart';
import 'package:deep_m/src/features/views/pages/playlist_folder_song.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:deep_m/src/features/viewmodels/playlist_provider.dart';

class PlaylistPage extends StatefulWidget {
  const PlaylistPage({super.key});

  @override
  State<PlaylistPage> createState() => _PlaylistPageState();
}

class _PlaylistPageState extends State<PlaylistPage> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeProviders();
    });
  }

  Future<void> _initializeProviders() async {
    if (_isInitialized) return;

    final playlistProvider = Provider.of<PlaylistProvider>(
      context,
      listen: false,
    );
    final downloadSongProvider = Provider.of<DownloadSongProvider>(
      context,
      listen: false,
    );

    playlistProvider.initDownloadSongProvider(context);
    await downloadSongProvider.loadDownloadStatus();

    await playlistProvider.downloadAllPendingSongs(context);

    _isInitialized = true;
  }

  @override
  Widget build(BuildContext context) {
    final playlistProvider = Provider.of<PlaylistProvider>(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body:
          playlistProvider.playlists.isEmpty
              ? _buildEmptyPlaylistView()
              : _buildPlaylistGrid(playlistProvider),
    );
  }

  Widget _buildEmptyPlaylistView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.playlist_add, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            "Belum ada playlist",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            "Tambahkan lagu ke playlist dari halaman pencarian",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaylistGrid(PlaylistProvider playlistProvider) {
    final List<String> playlistNames = playlistProvider.playlists.keys.toList();
    final int playlistCount = playlistNames.length;

    final int rowCount = (playlistCount / 2).ceil();

    return Padding(
      padding: const EdgeInsets.all(10),
      child: SingleChildScrollView(
        child: Column(
          children: List.generate(rowCount, (rowIndex) {
            final int itemsInThisRow =
                rowIndex == rowCount - 1 && playlistCount % 2 != 0 ? 1 : 2;

            return Row(
              children: List.generate(itemsInThisRow, (colIndex) {
                final int playlistIndex = rowIndex * 2 + colIndex;
                final String playlistName = playlistNames[playlistIndex];
                final int songCount =
                    playlistProvider.playlists[playlistName]!.length;

                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => PlaylistFolderSong(
                                  playlistName: playlistName,
                                ),
                          ),
                        );
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.all(10),
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.amber.shade100,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 1,
                            blurRadius: 3,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.music_note,
                            size: 40,
                            color: Colors.amber.shade700,
                          ),
                          SizedBox(height: 8),
                          Text(
                            playlistName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4),
                          Text(
                            "$songCount lagu",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            );
          }),
        ),
      ),
    );
  }
}
