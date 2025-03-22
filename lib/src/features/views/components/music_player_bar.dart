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
          borderRadius: BorderRadius.circular(10),
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
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Icon(Icons.skip_previous),

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

                                  Icon(Icons.skip_next),
                                ],
                              ),
                            ],
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
