import 'dart:async';
import 'dart:io';

import 'package:deep_m/src/features/viewmodels/buffering_audio_provider.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class MusicProvider extends ChangeNotifier {
  String currentTitle = '';
  String currentThumbnail = '';
  String currentChannel = '';
  String currentDescription = '';
  bool isBuffering = false;
  bool isPlaying = false;
  bool isPlayingOffline = false;

  final AudioPlayer audioPlayer = AudioPlayer();
  final YoutubeExplode youtube = YoutubeExplode();

  final Map<String, String> _audioStreamUrl = {};

  //Get Local Path
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  //Get Audio File
  Future<File> getAudioFile(String videoId) async {
    final path = await _localPath;
    return File('$path/$videoId.mp3');
  }

  // Cek apakah file sudah terdownload dan valid
  Future<bool> isAudioDownloaded(String videoId) async {
    try {
      final file = await getAudioFile(videoId);
      final exists = await file.exists();

      if (!exists) return false;

      final fileSize = await file.length();
      return fileSize > 10 * 1024; // Minimal 10KB
    } catch (e) {
      print("Error memeriksa file audio: $e");
      return false;
    }
  }

  // Cek apakah internet tersedia
  Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('youtube.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    } catch (e) {
      print("Error memeriksa koneksi: $e");
      return false;
    }
  }

  //Initialization of Bufering Audio
  BufferingAudio? bufferingAudio;

  MusicProvider(BuildContext context) {
    // Mendengarkan perubahan status pemutaran
    audioPlayer.playerStateStream.listen((state) {
      isPlaying = state.playing;
      if (state.playing && isBuffering) {
        isBuffering = false;
        notifyListeners();
      }
    });
  }

  void initBufferingAudio(BuildContext context) {
    bufferingAudio ??= Provider.of<BufferingAudio>(context, listen: false);
  }

  Future<void> playAudio(
    BuildContext context,
    String videoId,
    String title,
    String thumbnail,
    String channel,
    String description,
  ) async {
    if (videoId.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('ID Video kosong')));
      return;
    }

    initBufferingAudio(context);

    isBuffering = true;
    currentTitle = title;
    currentThumbnail = thumbnail;
    currentChannel = channel;
    currentDescription = description;
    notifyListeners();

    try {
      final file = await getAudioFile(videoId);
      final isDownloaded = await isAudioDownloaded(videoId);

      if (isDownloaded) {
        // Putar file lokal jika ada
        print("Memutar file lokal: $title");
        try {
          await audioPlayer.setFilePath(file.path);
          isPlayingOffline = true;
        } catch (e) {
          print("Error memutar file lokal: $e");
          // Jika gagal memutar file lokal, coba streaming
          isPlayingOffline = false;

          // Periksa koneksi sebelum streaming
          final hasInternet = await hasInternetConnection();
          if (!hasInternet) {
            throw Exception('Tidak ada koneksi internet dan file lokal rusak.');
          }

          await _playFromStream(videoId);
        }
      } else {
        // Periksa koneksi sebelum streaming
        final hasInternet = await hasInternetConnection();
        if (!hasInternet) {
          throw Exception('Tidak ada koneksi internet. Lagu belum didownload.');
        }

        // Stream dari YouTube
        isPlayingOffline = false;
        await _playFromStream(videoId);
      }

      await audioPlayer.seek(Duration.zero);
      bufferingAudio?.startPreBuffering(videoId);
      await audioPlayer.play();

      isPlaying = true;
      isBuffering = false;
      notifyListeners();

      await audioPlayer.setLoopMode(LoopMode.off);
      audioPlayer.positionStream.listen((position) {
        final playedSegments = bufferingAudio?.playedSegments;
        if (playedSegments != null) {
          if (playedSegments.containsKey(videoId)) {
            playedSegments[videoId]!.add(position);
          } else {
            playedSegments[videoId] = {position};
          }
        }
      });
    } catch (e) {
      isBuffering = false;
      notifyListeners();

      // Gunakan Future.microtask untuk menghindari blocking UI thread
      Future.microtask(() {
        try {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Gagal memutar audio: ${e.toString()}'),
                duration: Duration(seconds: 3),
              ),
            );
          }
        } catch (uiError) {
          debugPrint('Error UI: $uiError');
        }
      });

      audioPlayer.stop();
    }
  }

  // Metode untuk streaming dari YouTube
  Future<void> _playFromStream(String videoId) async {
    String? audioUrl = _audioStreamUrl[videoId];

    if (audioUrl == null) {
      try {
        print("Mencoba stream dari YouTube untuk: $videoId");
        var manifest = await youtube.videos.streamsClient.getManifest(videoId);
        var audioStreams = manifest.audioOnly.toList();
        audioStreams.sort((a, b) => b.bitrate.compareTo(a.bitrate));

        var audioStream = audioStreams.isNotEmpty ? audioStreams[0] : null;

        if (audioStream == null) {
          throw Exception('Audio tidak ditemukan');
        }

        audioUrl = audioStream.url.toString();
        _audioStreamUrl[videoId] = audioUrl;
        print("Streaming dari: ${audioStream.bitrate.kiloBitsPerSecond} kbps");
      } catch (e) {
        if (e.toString().contains('Socket') ||
            e.toString().contains('Connection')) {
          throw Exception(
            'Tidak ada koneksi internet. Download lagu ini dulu.',
          );
        }
        rethrow;
      }
    }

    await audioPlayer.setUrl(audioUrl);
  }

  void pauseAudio() async {
    await audioPlayer.pause();
    isPlaying = false;
    notifyListeners();
  }
}
