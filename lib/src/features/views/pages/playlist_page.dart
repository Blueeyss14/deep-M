import 'dart:ui';

import 'package:deep_m/src/features/viewmodels/download_song_provider.dart';
import 'package:deep_m/src/features/views/pages/playlist_folder_song.dart';
import 'package:deep_m/src/shared/style/custom_color.dart';
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
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 15),
            width: double.infinity,
            child: SafeArea(
              child: Text(
                "Search",
                style: TextStyle(
                  color: CustomColor.white1,
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.zero,
              child:
                  playlistProvider.playlists.isEmpty
                      ? _buildEmptyPlaylistView()
                      : _buildPlaylistGrid(playlistProvider),
            ),
          ),
        ],
      ),
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
                  child: ClipRect(
                    clipBehavior: Clip.antiAlias,
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 8),

                      child: Container(
                        padding: const EdgeInsets.all(15),
                        margin: const EdgeInsets.all(10),
                        height: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
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
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: 8),
                            Text(
                              playlistName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: CustomColor.white1,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (songCount == 1)
                              Text(
                                "$songCount song",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: CustomColor.white2,
                                ),
                              )
                            else
                              Text(
                                "$songCount songs",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: CustomColor.white2,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          );
        }),
      ),
    );
  }
}
