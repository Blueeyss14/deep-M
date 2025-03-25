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
        print("Peringatan: downloadSongProvider belum diinisialisasi");
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Ditambahkan ke playlist: $playlistName"),
          duration: Duration(seconds: 2),
        ),
      );
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
        print(
          "Error: Tidak bisa menyimpan playlist, downloadSongProvider null",
        );
        return;
      }

      final file = await downloadSongProvider!.getJsonFile(playlistsFileName);
      final playlistJson = json.encode(playlists);
      await file.writeAsString(playlistJson);
      print("Playlist tersimpan");
    } catch (e) {
      if (kDebugMode) {
        print('Error saat menyimpan playlist: $e');
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
  }

  // Download semua lagu yang belum terdownload
  Future<void> downloadAllPendingSongs(BuildContext context) async {
    if (downloadSongProvider == null || playlists.isEmpty) return;

    print("Memeriksa lagu-lagu yang belum didownload...");

    // Buat daftar lagu yang perlu didownload
    List<Map<String, String>> songsToDownload = [];

    for (var playlistName in playlists.keys) {
      for (var song in playlists[playlistName]!) {
        final videoId = song['videoId'];
        if (videoId == null || videoId.isEmpty) continue;

        // Periksa apakah file sudah ada
        final fileExists = await downloadSongProvider!.isAudioFileExists(
          videoId,
        );
        if (!fileExists &&
            !songsToDownload.any((s) => s['videoId'] == videoId)) {
          songsToDownload.add(song);
        }
      }
    }

    if (songsToDownload.isEmpty) {
      print("Semua lagu sudah terdownload");
      return;
    }

    print("Menemukan ${songsToDownload.length} lagu yang perlu didownload");

    // Tampilkan notifikasi
    if (context.mounted && songsToDownload.length > 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Mendownload ${songsToDownload.length} lagu..."),
          duration: Duration(seconds: 3),
        ),
      );
    }

    // Download lagu satu per satu
    for (var song in songsToDownload) {
      if (!context.mounted) break;

      await downloadSongProvider!.downloadAudio(
        song['videoId']!,
        song['title'] ?? 'Lagu tanpa judul',
        context,
      );

      // Beri jeda agar tidak membebani jaringan
      await Future.delayed(Duration(milliseconds: 500));
    }
  }

  Future<void> loadPlaylists() async {
    if (_isLoadingPlaylists) return;
    _isLoadingPlaylists = true;

    try {
      if (downloadSongProvider == null) {
        print(
          "Peringatan: Tidak bisa memuat playlist, downloadSongProvider null",
        );
        _isLoadingPlaylists = false;
        return;
      }

      final file = await downloadSongProvider!.getJsonFile(playlistsFileName);
      if (await file.exists()) {
        final playlistsJson = await file.readAsString();
        print("Memuat playlist dari penyimpanan...");

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
          print("Berhasil memuat ${playlists.length} playlist");

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
                } else {
                  // File exists, mark as downloaded
                  downloadSongProvider!.downloadStatus[videoId] = true;
                }
              }
            }
          }

          // Simpan status download yang diperbarui
          await downloadSongProvider!.saveDownloadStatus();
          notifyListeners();
        } catch (parseError) {
          print("Error saat parsing playlist: $parseError");
        }
      } else {
        print("Tidak ada file playlist, membuat yang baru");
      }
    } catch (e) {
      print('Error saat memuat playlist: $e');
    } finally {
      _isLoadingPlaylists = false;
    }
  }
}
