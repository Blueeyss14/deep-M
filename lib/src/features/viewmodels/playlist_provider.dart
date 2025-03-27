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
  bool _isLoadingPlaylists = false;

  void initDownloadSongProvider(BuildContext context) {
    if (!_isInitialized) {
      downloadSongProvider = Provider.of<DownloadSongProvider>(
        context,
        listen: false,
      );
      _isInitialized = true;
      loadPlaylists();
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

    bool songExists =
        playlists[playlistName]?.any(
          (item) => item['videoId'] == song['videoId'],
        ) ??
        false;

    if (!songExists) {
      playlists[playlistName]?.add(song);
      notifyListeners();

      if (downloadSongProvider != null) {
        downloadSongProvider!.downloadAudio(
          song['videoId']!,
          song['title']!,
          context,
        );
      } else {
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Ditambahkan ke playlist: $playlistName"),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
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
        print("Error: null");
        return;
      }

      final file = await downloadSongProvider!.getJsonFile(playlistsFileName);
      final playlistJson = json.encode(playlists);
      await file.writeAsString(playlistJson);
      print("Playlist tersimpan");
    } catch (e) {
      if (kDebugMode) {
        print('Error zzz: $e');
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

    if (playlists[playlistName]!.isEmpty) {
      playlists.remove(playlistName);
    }
    notifyListeners();

    await savePlaylist();
  }

  Future<void> downloadAllPendingSongs(BuildContext context) async {
    if (downloadSongProvider == null || playlists.isEmpty) return;

    print("checking download...");

    List<Map<String, String>> songsToDownload = [];

    for (var playlistName in playlists.keys) {
      for (var song in playlists[playlistName]!) {
        final videoId = song['videoId'];
        if (videoId == null || videoId.isEmpty) continue;

        final fileExists = await downloadSongProvider!.isAudioFileExists(
          videoId,
        );
        if (!fileExists &&
            !songsToDownload.any((s) => s['videoId'] == videoId)) {
          songsToDownload.add(song);
        }
      }
    }

    if (songsToDownload.isEmpty) return;

    print("${songsToDownload.length}");

    // notification
    if (context.mounted && songsToDownload.length > 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Downloading ${songsToDownload.length} songs..."),
          duration: Duration(seconds: 3),
        ),
      );
    }

    for (var song in songsToDownload) {
      if (!context.mounted) break;

      await downloadSongProvider!.downloadAudio(
        song['videoId']!,
        song['title'] ?? 'No Title',
        context,
      );

      await Future.delayed(Duration(milliseconds: 500));
    }
  }

  Future<void> loadPlaylists() async {
    if (_isLoadingPlaylists) return;
    _isLoadingPlaylists = true;

    try {
      if (downloadSongProvider == null) {
        _isLoadingPlaylists = false;
        return;
      }

      final file = await downloadSongProvider!.getJsonFile(playlistsFileName);
      if (await file.exists()) {
        final playlistsJson = await file.readAsString();

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

          for (var playlistName in playlists.keys) {
            for (var song in playlists[playlistName]!) {
              final videoId = song['videoId'];
              if (videoId != null) {
                final fileExists = await downloadSongProvider!
                    .isAudioFileExists(videoId);
                if (!fileExists) {
                  // download later
                  downloadSongProvider!.downloadStatus[videoId] = null;
                } else {
                  // File exists, mark as downloaded
                  downloadSongProvider!.downloadStatus[videoId] = true;
                }
              }
            }
          }

          // Simpan status download yg baru
          await downloadSongProvider!.saveDownloadStatus();
          notifyListeners();
        } catch (parseError) {
          print("Error: $parseError");
        }
      } else {
        print("No file playlist");
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      _isLoadingPlaylists = false;
    }
  }

  Future<void> deletePlaylist(String playlistName) async {
    playlists.remove(playlistName);
    notifyListeners();

    await savePlaylist();

    // if (mounted) {
    //   Navigator.pushReplacement(
    //     context,
    //     MaterialPageRoute(builder: (context) => _buildPlaylistPage()),
    //   );
    // }
  }
}
