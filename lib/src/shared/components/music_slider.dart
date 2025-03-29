import 'package:deep_m/src/features/viewmodels/music_provider.dart';
import 'package:deep_m/src/shared/style/custom_color.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MusicSlider extends StatelessWidget {
  const MusicSlider({super.key});

  @override
  Widget build(BuildContext context) {
    final audioPlayer = Provider.of<MusicProvider>(context);

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

                return Column(
                  children: [
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 2,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 4,
                        ),
                        overlayShape: const RoundSliderOverlayShape(
                          overlayRadius: 10,
                        ),
                        thumbColor: CustomColor.white1,
                        activeTrackColor: CustomColor.white1,
                        inactiveTrackColor: CustomColor.white3,
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
                          final newPosition = Duration(seconds: value.toInt());
                          await audioPlayer.audioPlayer.seek(newPosition);
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ],
    );
  }
}
