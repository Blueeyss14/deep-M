import 'package:cached_network_image/cached_network_image.dart';
import 'package:deep_m/src/features/viewmodels/music_provider.dart';
import 'package:deep_m/src/features/views/utils/music_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MusicPlayerBar extends StatefulWidget {
  const MusicPlayerBar({super.key});

  @override
  State<MusicPlayerBar> createState() => _MusicPlayerBarState();
}

class _MusicPlayerBarState extends State<MusicPlayerBar> {
  @override
  Widget build(BuildContext context) {
    final audioPlayer = Provider.of<MusicProvider>(context);

    return GestureDetector(
      onTap: () {
        setState(() {
          musicBottomSheet(context);
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey[400],
        ),
        clipBehavior: Clip.antiAlias,
        width: double.infinity,
        child: Column(
          children: [
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
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),

                            alignment: Alignment.topLeft,
                            child: LinearProgressIndicator(
                              value:
                                  duration.inSeconds > 0
                                      ? position.inSeconds / duration.inSeconds
                                      : 0,
                              backgroundColor: Colors.grey[300],
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.red,
                              ),
                              minHeight: 2,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Row(
                              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                if (audioPlayer.currentThumbnail.isEmpty)
                                  const Icon(Icons.music_note)
                                else
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(3),
                                    child: CachedNetworkImage(
                                      imageUrl: audioPlayer.currentThumbnail,
                                      width: 40,
                                      height: 40,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        audioPlayer.currentTitle,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        audioPlayer.currentChannel,
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),

                                if (audioPlayer.isPlaying)
                                  GestureDetector(
                                    onTap: () {
                                      audioPlayer.pauseAudio();
                                    },
                                    child: Icon(Icons.pause),
                                  )
                                else
                                  GestureDetector(
                                    onTap: () {
                                      audioPlayer.audioPlayer.play();
                                    },
                                    child: Icon(Icons.play_arrow),
                                  ),
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
          ],
        ),
      ),
    );
  }
}
