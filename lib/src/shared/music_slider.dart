import 'package:deep_m/src/features/viewmodels/music_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MusicSlider extends StatelessWidget {
  const MusicSlider({super.key});

  @override
  Widget build(BuildContext context) {
    final audioPlayer = Provider.of<MusicProvider>(context);

    // String formatDuration(Duration duration) {
    //   final minutes = duration.inMinutes
    //       .remainder(60)
    //       .toString()
    //       .padLeft(2, '0');
    //   final seconds = duration.inSeconds
    //       .remainder(60)
    //       .toString()
    //       .padLeft(2, '0');
    //   return '$minutes:$seconds';
    // }

    return Column(
      mainAxisSize: MainAxisSize.min,
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
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(horizontal: 10),
                      //   child: Row(
                      //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //     children: [
                      //       Text(formatDuration(position)),
                      //       Text(formatDuration(duration)),
                      //     ],
                      //   ),
                      // ),
                    ],
                  );
                }
              },
            );
          },
        ),
      ],
    );
  }
}
