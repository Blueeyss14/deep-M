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

    downloadSongProvider?.downloadAudio(song['videoId']!, song['title']!);
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

  Future<void> removeSongFromPlaylist(
    String playlistName,
    Map<String, String> song,
  ) async {
    playlists[playlistName]!.removeWhere(
      (item) => item['videoId'] == song['videoId'],
    );

    // delete playlist if isEmpty
    if (playlists[playlistName]!.isEmpty) {
      playlists.remove(playlistName);
    }
    notifyListeners();

    // save playlist changes
    await savePlaylist();
    notifyListeners();
  }

  Future<void> loadPlaylists() async {
    try {
      final file = await downloadSongProvider!.getJsonFile(playlistsFileName);
      if (await file.exists()) {
        final playlistsJson = await file.readAsString();
        final Map<String, dynamic> decoded = json.decode(playlistsJson);
        playlists = Map<String, List<Map<String, String>>>.from(
          decoded.map(
            (key, value) => MapEntry(
              key,
              List<Map<String, String>>.from(
                (value as List).map((item) => Map<String, String>.from(item)),
              ),
            ),
          ),
        );
        notifyListeners();
      }
    } catch (e) {
      print('Error loading playlists: $e');
    }
  }
}
