import 'dart:convert';
import 'dart:io';

import 'package:deep_m/src/features/viewmodels/music_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class DownloadSongProvider extends ChangeNotifier {
  MusicProvider? musicProvider;
  final YoutubeExplode youtube = YoutubeExplode();
  bool _isMusicProviderInitialized = false;

  static const String _downloadStatusFileName = 'download_status.json';

  void initMusicProvider(BuildContext context) {
    if (!_isMusicProviderInitialized) {
      musicProvider = Provider.of<MusicProvider>(context, listen: false);
      _isMusicProviderInitialized = true;
    }
  }

  // Map with videoId as key and download status as value
  // true = downloaded, false = downloading, null = not downloaded
  Map<String, bool?> downloadStatus = {};

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> getAudioFile(String videoId) async {
    final path = await _localPath;
    return File('$path/$videoId.mp3');
  }

  Future<bool> isAudioFileExists(String videoId) async {
    try {
      final file = await getAudioFile(videoId);
      final exists = await file.exists();
      final fileSize = exists ? await file.length() : 0;

      // Verifikasi bahwa file tidak kosong (minimal 10KB)
      return exists && fileSize > 10 * 1024;
    } catch (e) {
      print("Error memeriksa file: $e");
      return false;
    }
  }

  // Fungsi untuk paksa download ulang
  Future<void> forceRedownload(
    String videoId,
    String title,
    BuildContext context,
  ) async {
    // Hapus file lama jika ada
    final file = await getAudioFile(videoId);
    if (await file.exists()) {
      await file.delete();
    }

    // Reset status download
    downloadStatus[videoId] = null;
    notifyListeners();

    // Download ulang
    await downloadAudio(videoId, title, context);
  }

  Future<void> downloadAudio(
    String videoId,
    String title,
    BuildContext context, {
    bool forceDownload = false,
  }) async {
    if (videoId.isEmpty) {
      print("Error: videoId kosong, tidak dapat mendownload");
      return;
    }

    // Initialize music provider if not already done
    if (musicProvider == null) {
      initMusicProvider(context);
    }

    // First, check if file already exists
    final file = await getAudioFile(videoId);
    final exists = await file.exists();

    if (exists && !forceDownload) {
      final fileSize = await file.length();

      if (fileSize > 10 * 1024) {
        // Minimal 10KB
        downloadStatus[videoId] = true;
        await saveDownloadStatus();
        notifyListeners();
        print("File sudah ada: ${file.path} (${fileSize ~/ 1024} KB)");
        return;
      } else {
        // File ada tapi kosong/corrupt
        print("File ada tapi sepertinya rusak, mendownload ulang...");
        await file.delete();
      }
    }

    // Don't download if already downloading
    if (downloadStatus[videoId] == false) {
      print("Sudah dalam proses download, menunggu...");
      return;
    }

    downloadStatus[videoId] = false;
    notifyListeners();

    try {
      print("Mulai download lagu: $title (ID: $videoId)");
      // Use the injected YouTube instance instead of relying on musicProvider
      final manifest = await youtube.videos.streamsClient.getManifest(videoId);
      final audioStreams = manifest.audioOnly.toList();

      if (audioStreams.isEmpty) {
        throw Exception('Tidak ada audio yang tersedia untuk lagu ini');
      }

      // Pilih kualitas audio tertinggi agar tidak terlalu kecil
      audioStreams.sort((a, b) => b.bitrate.compareTo(a.bitrate));
      final audioStream = audioStreams.first;

      print(
        "Mendapatkan audio: ${audioStream.bitrate.kiloBitsPerSecond} kbps, ${audioStream.size.totalMegaBytes.toStringAsFixed(2)} MB",
      );

      final fileStream = file.openWrite();
      final len = audioStream.size.totalBytes;
      var count = 0;

      await for (final data in youtube.videos.streamsClient.get(audioStream)) {
        count += data.length;
        fileStream.add(data);

        // Display progress percentage
        final progress = (count / len * 100).toStringAsFixed(0);
        if (int.parse(progress) % 10 == 0) {
          // Only log every 10%
          print("Download progress: $progress% untuk $title");
        }

        downloadStatus[videoId] = false;
        notifyListeners();
      }

      await fileStream.flush();
      await fileStream.close();

      // Verifikasi file
      final fileSize = await file.length();
      if (fileSize < 10 * 1024) {
        // Kurang dari 10KB
        throw Exception(
          'File hasil download terlalu kecil (${fileSize ~/ 1024} KB), kemungkinan error',
        );
      }

      print("Download selesai: ${file.path} (${fileSize ~/ 1024} KB)");
      downloadStatus[videoId] = true;
      await saveDownloadStatus();
      notifyListeners();

      // Tampilkan notifikasi bahwa lagu sudah tersedia offline
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lagu "$title" tersedia offline'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print("Download error: $e");

      // Set to null to indicate download failed
      downloadStatus[videoId] = null;
      await saveDownloadStatus();
      notifyListeners();

      // Show error message if context is still valid
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mendownload: ${e.toString()}'),
            duration: Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Coba Lagi',
              onPressed: () {
                forceRedownload(videoId, title, context);
              },
            ),
          ),
        );
      }
    }
  }

  Future<void> saveDownloadStatus() async {
    try {
      final file = await getJsonFile(_downloadStatusFileName);
      final downloadStatusJson = json.encode(downloadStatus);
      await file.writeAsString(downloadStatusJson);
    } catch (e) {
      if (kDebugMode) {
        print('Error menyimpan status download: $e');
      }
    }
  }

  Future<File> getJsonFile(String fileName) async {
    final path = await _localPath;
    return File('$path/$fileName');
  }

  Future<void> loadDownloadStatus() async {
    try {
      final file = await getJsonFile(_downloadStatusFileName);
      if (await file.exists()) {
        final downloadStatusJson = await file.readAsString();
        final Map<String, dynamic> decoded = json.decode(downloadStatusJson);

        // Convert the status values and update downloadStatus
        downloadStatus = Map<String, bool?>.from(
          decoded.map((key, value) => MapEntry(key, value as bool?)),
        );

        // Verify that downloaded files actually exist
        for (final videoId in downloadStatus.keys.toList()) {
          final exists = await isAudioFileExists(videoId);
          if (!exists && downloadStatus[videoId] == true) {
            // File marked as downloaded but doesn't exist
            print(
              "File untuk $videoId ditandai sudah didownload tapi tidak ditemukan",
            );
            downloadStatus[videoId] = null;
          }
        }

        await saveDownloadStatus(); // Save any corrections
        notifyListeners();
      }
    } catch (e) {
      print('Error loading download status: $e');
    }
  }
}
