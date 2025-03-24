import 'dart:convert';

import 'package:deep_m/src/features/viewmodels/download_song_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PlaylistProvider extends ChangeNotifier {
  Map<String, List<Map<String, String>>> playlists = {};

  static const String playlistsFileName = 'playlists.json';

  Map<String, bool> downloadStatus = {};

  DownloadSongProvider? downloadSongProvider;

  void initDownloadSongProvider(BuildContext context) {
    downloadSongProvider = Provider.of<DownloadSongProvider>(
      context,
      listen: false,
    );
  }

  Future<void> addToPlaylist(
    String playlistName,
    Map<String, String> song,
  ) async {
    if (!playlists.containsKey(playlistName)) {
      playlists[playlistName] = [];
    }
    playlists[playlistName]!.add(song);
    notifyListeners();
  }

  Future<void> savePlaylist() async {
    try {
      final file = await downloadSongProvider!.getJsonFile(playlistsFileName);
      final playlistJson = json.decode(playlists.toString());
      await file.writeAsString(json.encode(playlistJson));
    } catch (e) {
      if (kDebugMode) {
        print('Error saving playlist: $e');
      }
    }
  }
}
