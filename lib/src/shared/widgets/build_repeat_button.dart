import 'package:deep_m/src/features/viewmodels/music_provider.dart';
import 'package:deep_m/src/shared/style/custom_color.dart';
import 'package:flutter/material.dart';

Widget buildRepeatModeButton(
  BuildContext context,
  MusicProvider musicProvider,
  StateSetter setState,
) {
  final bool isPlaylist = musicProvider.isPlayingFromPlaylist;

  IconData iconData;
  Color iconColor;
  String tooltip;

  switch (musicProvider.repeatMode) {
    case RepeatMode.none:
      iconData = Icons.repeat;
      iconColor = CustomColor.white3;
      tooltip = 'Play once';
      break;
    case RepeatMode.playlist:
      iconData = Icons.repeat;
      iconColor = isPlaylist ? CustomColor.white1 : CustomColor.white3;
      tooltip = isPlaylist ? 'Play all song' : '';
      break;
    case RepeatMode.single:
      iconData = Icons.repeat_one;
      iconColor = CustomColor.white1;
      tooltip = 'Repeat';
      break;
  }

  return IconButton(
    icon: Icon(iconData, color: iconColor, size: 24),
    tooltip: tooltip,
    onPressed: () {
      if (musicProvider.repeatMode == RepeatMode.none && !isPlaylist) {
        musicProvider.toggleLoopMode();
        musicProvider.toggleLoopMode();
      } else {
        musicProvider.toggleLoopMode();
      }
      setState(() {});
    },
  );
}
