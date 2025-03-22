import 'package:deep_m/src/features/viewmodels/music_provider.dart';
import 'package:deep_m/src/shared/current_song_text.dart';
import 'package:deep_m/src/shared/music_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void musicBottomSheet(BuildContext context) {
  final audioPlayer = Provider.of<MusicProvider>(context, listen: false);

  showModalBottomSheet(
    context: context,
    builder:
        (context) => Column(
          // mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              audioPlayer.currentTitle,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            MusicSlider(),
            CurrentSongText(),
          ],
        ),
  );
}
