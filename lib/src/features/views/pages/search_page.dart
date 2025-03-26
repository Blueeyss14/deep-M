import 'package:cached_network_image/cached_network_image.dart';
import 'package:deep_m/src/features/viewmodels/music_provider.dart';
import 'package:deep_m/src/features/viewmodels/search_song_provider.dart';
import 'package:deep_m/src/features/views/components/textfield_search.dart';
import 'package:deep_m/src/features/views/utils/add_playlist_bottom_sheet.dart';
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextfieldSearch(),
            const SizedBox(height: 10),

            Expanded(
              child:
                  searchProvider.isLoading
                      ? Center(child: CircularProgressIndicator())
                      : searchProvider.searchController.text.isNotEmpty
                      ? ListView.builder(
                        itemCount: searchProvider.searchResult.length + 1,
                        itemBuilder: (context, index) {
                          //Nambahin Sized box di bawah list lagu biar gak ketutupan
                          if (index == searchProvider.searchResult.length) {
                            return SizedBox(
                              height: MediaQuery.of(context).size.height / 4,
                            );
                          }

                          final result = searchProvider.searchResult[index];

                          return GestureDetector(
                            onTap: () {
                              musicProvider.playAudio(
                                context,
                                result['videoId'] ?? '',
                                result['title'] ?? 'Tidak Ada',
                                result['thumbnail'] ?? '',
                                result['channel'] ?? 'Tidak Ada',
                                result['description'] ?? 'Tidak Ada',
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 10),
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
                                            color: const Color(0xFFF1F1F1),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          result['channel'] ?? '',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: const Color(0xFFDADADA),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        addPlaylistBottomSheet(context, result);
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
                      )
                      : Center(child: Text('Tidak Ada Hasil')),
            ),
          ],
        ),
      ),
    );
  }
}
