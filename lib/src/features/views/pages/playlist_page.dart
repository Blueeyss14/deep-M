import 'dart:ui';

import 'package:deep_m/src/features/viewmodels/download_song_provider.dart';
import 'package:deep_m/src/features/views/dialog/delete_playlist_dialog.dart';
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

    if (!mounted) return;

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

    if (!mounted) return;
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
                "Playlist",
                style: TextStyle(
                  color: CustomColor.white1,
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                ),
              ),
            ),
          ),

          if (playlistProvider.playlists.isEmpty)
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "GET OUT 🗣🗣",
                    style: TextStyle(fontSize: 16, color: CustomColor.white2),
                  ),
                  const SizedBox(height: 5),

                  Text(
                    "No Playlist Created",
                    style: TextStyle(fontSize: 16, color: CustomColor.white2),
                  ),
                  const SizedBox(height: 60),
                ],
              ),
            )
          else
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 200),
                child: _buildPlaylistGrid(playlistProvider),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlaylistGrid(PlaylistProvider playlistProvider) {
    final List<String> playlistNames = playlistProvider.playlists.keys.toList();
    final int playlistCount = playlistNames.length;

    return Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        children: [
          for (int i = 0; i < playlistCount; i += 2)
            Row(
              children: [
                Expanded(
                  child: _buildPlaylistItem(playlistNames[i], playlistProvider),
                ),
                if (i + 1 < playlistCount)
                  Expanded(
                    child: _buildPlaylistItem(
                      playlistNames[i + 1],
                      playlistProvider,
                    ),
                  )
                else
                  Expanded(child: SizedBox()),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildPlaylistItem(
    String playlistName,
    PlaylistProvider playlistProvider,
  ) {
    final int songCount = playlistProvider.playlists[playlistName]!.length;

    return GestureDetector(
      onLongPress: () {
        deletePlaylistDialog(context, playlistName, playlistProvider);
      },
      onTap: () {
        setState(() {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => PlaylistFolderSong(playlistName: playlistName),
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
            margin: EdgeInsets.all(10),
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
                Text(
                  "$songCount song${songCount > 1 ? 's' : ''}",
                  style: TextStyle(fontSize: 12, color: CustomColor.white2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
