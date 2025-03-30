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

  String progress = '';

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

      // Verifikasi bahwa file tidak kosong (minimal 10KB lah)
      return exists && fileSize > 10 * 1024;
    } catch (e) {
      print("Error checking file: $e");
      return false;
    }
  }

  // force to download
  Future<void> forceRedownload(
    String videoId,
    String title,
    BuildContext context,
  ) async {
    // delete old file if exists
    final file = await getAudioFile(videoId);
    if (await file.exists()) {
      await file.delete();
    }

    // Reset status download
    downloadStatus[videoId] = null;
    notifyListeners();

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

    if (musicProvider == null) {
      initMusicProvider(context);
    }

    // First, check if file already exists
    final file = await getAudioFile(videoId);
    final exists = await file.exists();

    if (exists && !forceDownload) {
      final fileSize = await file.length();

      if (fileSize > 10 * 1024) {
        // 10kb
        downloadStatus[videoId] = true;
        await saveDownloadStatus();
        notifyListeners();
        print("File is exists: ${file.path} (${fileSize ~/ 1024} KB)");
        return;
      } else {
        await file.delete();
      }
    }

    // Don't download if already downloading
    if (downloadStatus[videoId] == false) return;

    downloadStatus[videoId] = false;
    notifyListeners();

    try {
      print("start download: $title (ID: $videoId)");
      final manifest = await youtube.videos.streamsClient.getManifest(videoId);
      final audioStreams = manifest.audioOnly.toList();

      if (audioStreams.isEmpty) {
        throw Exception('No audio available');
      }

      audioStreams.sort((a, b) => b.bitrate.compareTo(a.bitrate));
      final audioStream = audioStreams.first;

      print(
        "Get the audio quality: ${audioStream.bitrate.kiloBitsPerSecond} kbps, ${audioStream.size.totalMegaBytes.toStringAsFixed(2)} MB",
      );

      final fileStream = file.openWrite();
      final len = audioStream.size.totalBytes;
      var count = 0;

      await for (final data in youtube.videos.streamsClient.get(audioStream)) {
        count += data.length;
        fileStream.add(data);

        // Display progress percentage
        progress = (count / len * 100).toStringAsFixed(0);
        if (int.parse(progress) % 10 == 0) {
          // log every 10%
          print("Download progress: $progress% for $title");
        }
        if (int.parse(progress) >= 100) downloadStatus[videoId] = false;

        notifyListeners();
      }

      await fileStream.flush();
      await fileStream.close();

      final fileSize = await file.length();
      if (fileSize < 10 * 1024) {
        // Kurang dari 10KB
        throw Exception('(${fileSize ~/ 1024} KB)');
      }

      print("Download selesai: ${file.path} (${fileSize ~/ 1024} KB)");
      downloadStatus[videoId] = true;
      await saveDownloadStatus();
      notifyListeners();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"$title" is available offline'),
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

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to download: ${e.toString()}'),
            duration: Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Try Again',
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
        print('Error saving download status: $e');
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
            downloadStatus[videoId] = null;
          }
        }

        await saveDownloadStatus();
        notifyListeners();
      }
    } catch (e) {
      print('Error loading download status: $e');
    }
  }
}
