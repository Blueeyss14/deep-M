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
      ).showSnackBar(const SnackBar(content: Text('Video is empty')));
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

      if (await file.exists()) {
        // Play local file if it exists
        print("Playing local file for: $title");
        await audioPlayer.setFilePath(file.path);
      } else {
        // Otherwise attempt to stream
        String? audioUrl = _audioStreamUrl[videoId];

        if (audioUrl == null) {
          try {
            var manifest = await youtube.videos.streamsClient.getManifest(
              videoId,
            );
            var audioStreams = manifest.audioOnly.toList();
            audioStreams.sort((a, b) => a.bitrate.compareTo(b.bitrate));

            var audioStream = audioStreams.isNotEmpty ? audioStreams[0] : null;

            if (audioStream == null) {
              throw Exception('Audio Stream Not Found');
            }

            audioUrl = audioStream.url.toString();
            _audioStreamUrl[videoId] = audioUrl;
          } catch (e) {
            if (e.toString().contains('Socket') ||
                e.toString().contains('Connection')) {
              throw Exception(
                'No Internet Connection. Try downloading this song first.',
              );
            }
            rethrow;
          }
        }
        await audioPlayer.setUrl(audioUrl);
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
              SnackBar(content: Text('Gagal memutar audio: ${e.toString()}')),
            );
          }
        } catch (uiError) {
          debugPrint('Error: $uiError');
        }
      });

      audioPlayer.stop();
    }
  }

  void pauseAudio() async {
    await audioPlayer.pause();
    isPlaying = false;
    notifyListeners();
  }
}
