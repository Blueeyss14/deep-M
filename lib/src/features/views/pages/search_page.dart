import 'package:cached_network_image/cached_network_image.dart';
import 'package:deep_m/src/features/viewmodels/music_provider.dart';
import 'package:deep_m/src/features/viewmodels/search_song_provider.dart';
import 'package:deep_m/src/features/views/components/textfield_search.dart';
import 'package:deep_m/src/features/views/utils/add_playlist_bottom_sheet.dart';
import 'package:deep_m/src/shared/style/custom_color.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  Widget build(BuildContext context) {
    final searchProvider = Provider.of<SearchSongProvider>(context);
    final musicProvider = Provider.of<MusicProvider>(context, listen: false);
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ///APPBAR
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(height: 25),
                  Text(
                    "Search",
                    style: TextStyle(
                      color: CustomColor.white1,
                      fontWeight: FontWeight.bold,
                      fontSize: 32,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextfieldSearch(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            Expanded(
              child:
                  searchProvider.searchController.text.isNotEmpty
                      ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: searchProvider.searchResult.length + 1,
                          itemBuilder: (context, index) {
                            //Nambahin Sized box di bawah list lagu biar gak ketutupan
                            if (index == searchProvider.searchResult.length) {
                              return SizedBox(height: 200);
                            }

                            final result = searchProvider.searchResult[index];

                            return GestureDetector(
                              onTap: () {
                                musicProvider.playAudio(
                                  context,
                                  result['videoId'] ?? '',
                                  result['title'] ?? '',
                                  result['thumbnail'] ?? '',
                                  result['channel'] ?? '',
                                  result['description'] ?? '',
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                color: Colors.transparent,
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(3),
                                      child: CachedNetworkImage(
                                        imageUrl: result['thumbnail']!,
                                        width: 48,
                                        height: 48,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const SizedBox(width: 12),

                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            result['title'] ?? '',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: CustomColor.white1,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            result['channel'] ?? '',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: CustomColor.white2,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          addPlaylistBottomSheet(
                                            context,
                                            result,
                                          );
                                        });
                                      },
                                      child: Icon(
                                        Icons.more_vert,
                                        color: const Color(0xFFF1F1F1),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      )
                      : Center(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 60),
                          child: Text(
                            'Search Song',
                            style: TextStyle(color: CustomColor.white2),
                          ),
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
