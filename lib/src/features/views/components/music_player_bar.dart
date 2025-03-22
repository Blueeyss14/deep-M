import 'package:deep_m/src/features/viewmodels/music_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MusicPlayerBar extends StatefulWidget {
  const MusicPlayerBar({super.key});

  @override
  State<MusicPlayerBar> createState() => _MusicPlayerBarState();
}

class _MusicPlayerBarState extends State<MusicPlayerBar> {
  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final audioPlayer = Provider.of<MusicProvider>(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      // padding: const EdgeInsets.all(10),
      color: Colors.grey[400],
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
                            minHeight: 3,
                          ),
                        ),
                        Column(
                          children: [
                            Text(
                              audioPlayer.currentTitle,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                                  await audioPlayer.audioPlayer.seek(
                                    newPosition,
                                  );
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(_formatDuration(position)),
                                  Text(_formatDuration(duration)),
                                ],
                              ),
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
    );
  }
}
