import 'package:cached_network_image/cached_network_image.dart';
import 'package:deep_m/src/features/viewmodels/music_provider.dart';
import 'package:deep_m/src/shared/current_song_text.dart';
import 'package:deep_m/src/shared/music_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void musicBottomSheet(BuildContext context) {
  final audioPlayer = Provider.of<MusicProvider>(context, listen: false);

  showModalBottomSheet(
    clipBehavior: Clip.antiAlias,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    context: context,
    builder:
        (context) => Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppBar(elevation: 0, backgroundColor: Colors.transparent),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child:
                      audioPlayer.currentThumbnail.isNotEmpty
                          ? CachedNetworkImage(
                            imageUrl: audioPlayer.currentThumbnail,
                            width: 300,
                            height: 300,
                            fit: BoxFit.cover,
                          )
                          : const SizedBox(),
                ),
                const SizedBox(height: 10),
                Text(
                  audioPlayer.currentTitle,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  audioPlayer.currentChannel.isNotEmpty
                      ? audioPlayer.currentChannel
                      : '',
                ),
                const SizedBox(height: 10),

                StreamBuilder(
                  stream: audioPlayer.audioPlayer.positionStream,
                  builder: (
                    BuildContext context,
                    AsyncSnapshot<Duration> snapshot,
                  ) {
                    return Row(
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
                    );
                  },
                ),
                MusicSlider(),
                CurrentSongText(),
                // const SizedBox(height: 1000),
                if (audioPlayer.currentDescription.isNotEmpty)
                  Text(audioPlayer.currentDescription)
                else
                  const SizedBox(),
              ],
            ),
          ),
        ),
  );
}
