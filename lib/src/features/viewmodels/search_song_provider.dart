import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:just_audio/just_audio.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:http/http.dart' as http;

class SearchSong extends ChangeNotifier {
  final TextEditingController searchController = TextEditingController();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final YoutubeExplode _youtube = YoutubeExplode();

  bool isPlaying = false;
  bool isLoading = false;

  List<Map<String, String>> searchResult = [];

  String get _apiKey => dotenv.env['YOUTUBE_API_KEY'] ?? '';

  Future<void> searchVideos(String query) async {
    if (query.trim().isEmpty) return;

    isLoading = true;
    searchResult = [];

    try {
      final response = await http.get(
        Uri.parse(
          'https://www.googleapis.com/youtube/v3/search?part=snippet&maxResults=20&q=$query&type=video&videoCategoryId=10&key=$_apiKey',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['error'] != null) {
          String errorMessage = 'Terjadi Kesalahan';

          if (data['error']['code'] == 403) {
            errorMessage = 'Limit API Habis';
          } else if (data['error']['code'] == 400) {
            errorMessage = 'API Key Salah';
          }
          throw Exception(errorMessage);
        }

        if (data['items'] != null) {
          searchResult =
              (data['items'] as List)
                  .where((item) => item['id']['kind'] == 'youtube#video')
                  .map((item) {
                    return {
                      'title':
                          (item['snippet']['title'] ?? 'No Title').toString(),
                      'videoId': (item['id']['videoId'] ?? '').toString(),
                      'thumbnail':
                          (item['snippet']['thumbnails']['default']['url'] ??
                                  '')
                              .toString(),
                    };
                  })
                  .toList();
        } else {
          throw Exception('Gagal mencari video');
        }
      }
    } catch (e) {
      String errorMessage = 'Gagal mencari video';
      if (e.toString().contains('Socket') ||
          e.toString().contains('Connection')) {
        errorMessage = 'No Internet';
      } else if (e.toString().contains('Limit API Habis')) {
        errorMessage = 'Limit API Habis';
      } else if (e.toString().contains('API Key Salah')) {
        errorMessage = 'API Key Salah';
      }
    } finally {
      isLoading = false;
    }

    notifyListeners();
  }
}
