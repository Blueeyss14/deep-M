import 'package:deep_m/src/features/viewmodels/music_provider.dart';
import 'package:deep_m/src/features/viewmodels/search_song_provider.dart';
import 'package:deep_m/src/features/views/components/textfield_search.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final searchProvider = Provider.of<SearchSongProvider>(context);
    final audioPlayer = Provider.of<MusicProvider>(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextfieldSearch(),
            const SizedBox(height: 10),
            StreamBuilder(
              stream: audioPlayer.audioPlayer.positionStream,
              builder: (context, positionSnapshot) {
                final position = positionSnapshot.data ?? Duration.zero;

                return StreamBuilder(
                  stream: audioPlayer.audioPlayer.durationStream,
                  builder: (context, durationSnapshot) {
                    final duration = durationSnapshot.data ?? Duration.zero;

                    if (audioPlayer.isBuffering) {
                      return const CircularProgressIndicator();
                    } else {
                      return Column(
                        children: [
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 5,
                              ),
                              overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 14,
                              ),
                              thumbColor: Colors.red,
                              activeTrackColor: Colors.red,
                              inactiveTrackColor: Colors.grey[300],
                            ),
                            child: Slider(
                              min: 0,
                              max:
                                  duration.inSeconds.toDouble() > 0
                                      ? duration.inSeconds.toDouble()
                                      : 0.1,
                              value: position.inSeconds.toDouble().clamp(
                                0,
                                duration.inSeconds.toDouble() > 0
                                    ? duration.inSeconds.toDouble()
                                    : 0.1,
                              ),
                              onChanged: (value) async {
                                final newPosition = Duration(
                                  seconds: value.toInt(),
                                );
                                await audioPlayer.audioPlayer.seek(newPosition);
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(_formatDuration(position)),
                                Text(_formatDuration(duration)),
                              ],
                            ),
                          ),
                        ],
                      );
                    }
                  },
                );
              },
            ),

            Expanded(
              child:
                  searchProvider.isLoading
                      ? Center(child: CircularProgressIndicator())
                      : searchProvider.searchController.text.isNotEmpty
                      ? ListView.builder(
                        itemCount: searchProvider.searchResult.length,
                        itemBuilder: (context, index) {
                          final result = searchProvider.searchResult[index];

                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  result['title'] ?? 'Tidak Ada',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  final musicProvider =
                                      Provider.of<MusicProvider>(
                                        context,
                                        listen: false,
                                      );

                                  musicProvider.playAudio(
                                    context,
                                    result['videoId'] ?? '',
                                    result['title'] ?? 'Tidak Ada',
                                  );
                                },
                                icon: Icon(Icons.play_arrow),
                              ),
                            ],
                          );
                        },
                      )
                      : Center(child: Text('Tidak Ada Hasil')),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
