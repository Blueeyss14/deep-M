import 'dart:convert';

import 'package:deep_m/src/features/viewmodels/download_song_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PlaylistProvider extends ChangeNotifier {
  Map<String, List<Map<String, String>>> playlists = {};

  static const String playlistsFileName = 'playlists.json';

  DownloadSongProvider? downloadSongProvider;
  bool _isInitialized = false;

  void initDownloadSongProvider(BuildContext context) {
    if (!_isInitialized) {
      downloadSongProvider = Provider.of<DownloadSongProvider>(
        context,
        listen: false,
      );
      _isInitialized = true;
      loadPlaylists(); // Load playlists once the provider is initialized
    }
  }

  Future<void> addToPlaylist(
    String playlistName,
    Map<String, String> song,
    BuildContext context,
  ) async {
    if (!playlists.containsKey(playlistName)) {
      playlists[playlistName] = [];
    }

    // Check if song already exists in the playlist
    bool songExists =
        playlists[playlistName]?.any(
          (item) => item['videoId'] == song['videoId'],
        ) ??
        false;

    if (!songExists) {
      playlists[playlistName]?.add(song);
      notifyListeners();

      if (downloadSongProvider != null) {
        // Start downloading the song automatically when added to playlist
        downloadSongProvider!.downloadAudio(
          song['videoId']!,
          song['title']!,
          context,
        );
      } else {
        print("Warning: downloadSongProvider not initialized");
        // Try to initialize it
        initDownloadSongProvider(context);
        if (downloadSongProvider != null) {
          downloadSongProvider!.downloadAudio(
            song['videoId']!,
            song['title']!,
            context,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Gagal mendownload lagu, coba lagi nanti"),
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
      await savePlaylist();
    } else {
      // If song already exists, just show a message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lagu sudah ada di playlist"),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> savePlaylist() async {
    try {
      if (downloadSongProvider == null) {
        print("Error: Cannot save playlist, downloadSongProvider is null");
        return;
      }

      final file = await downloadSongProvider!.getJsonFile(playlistsFileName);
      final playlistJson = json.encode(playlists);
      await file.writeAsString(playlistJson);
      print("Playlist tersimpan");
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
      if (downloadSongProvider == null) {
        print("Warning: Cannot load playlists, downloadSongProvider is null");
        return;
      }

      final file = await downloadSongProvider!.getJsonFile(playlistsFileName);
      if (await file.exists()) {
        final playlistsJson = await file.readAsString();
        print("Loading playlists from storage...");

        try {
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
          print("Successfully loaded ${playlists.length} playlists");

          // Check if any songs need to be downloaded
          for (var playlistName in playlists.keys) {
            for (var song in playlists[playlistName]!) {
              final videoId = song['videoId'];
              if (videoId != null) {
                final fileExists = await downloadSongProvider!
                    .isAudioFileExists(videoId);
                if (!fileExists) {
                  // Song file doesn't exist, mark it for download later
                  downloadSongProvider!.downloadStatus[videoId] = null;
                }
              }
            }
          }

          notifyListeners();
        } catch (parseError) {
          print("Error parsing playlists: $parseError");
        }
      } else {
        print("No playlist file found, creating a new one");
      }
    } catch (e) {
      print('Error loading playlists: $e');
    }
  }
}
