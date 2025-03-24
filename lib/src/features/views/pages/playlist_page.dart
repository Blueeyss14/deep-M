import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:deep_m/src/features/viewmodels/music_provider.dart';
import 'package:deep_m/src/features/viewmodels/playlist_provider.dart';

class PlaylistPage extends StatelessWidget {
  const PlaylistPage({super.key});

  @override
  Widget build(BuildContext context) {
    final playlistProvider = Provider.of<PlaylistProvider>(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: playlistProvider.playlists.length,
          itemBuilder: (context, index) {
            String playlistName = playlistProvider.playlists.keys.elementAt(
              index,
            );
            List<Map<String, String>> songs =
                playlistProvider.playlists[playlistName]!;

            if (playlistName.isNotEmpty) {
              return ExpansionTile(
                title: Text(playlistName),
                children:
                    songs.map((song) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: GestureDetector(
                          onTap: () {
                            final musicProvider = Provider.of<MusicProvider>(
                              context,
                              listen: false,
                            );
                            musicProvider.playAudio(
                              context,
                              song['videoId'] ?? '',
                              song['title'] ?? 'Tidak Ada',
                              song['thumbnail'] ?? '',
                              song['channel'] ?? 'Tidak Ada',
                              song['description'] ?? 'Tidak Ada',
                            );
                          },
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(3),
                                child: Image.network(
                                  song['thumbnail'] ?? '',
                                  width: 48,
                                  height: 48,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      song['title'] ?? 'Tidak Ada',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      song['channel'] ?? 'Tidak Ada',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
              );
            } else {
              return Center(child: Text("No Playlist"));
            }
          },
        ),
      ),
    );
  }
}
