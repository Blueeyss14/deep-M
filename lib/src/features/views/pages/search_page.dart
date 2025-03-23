import 'package:cached_network_image/cached_network_image.dart';
import 'package:deep_m/src/features/viewmodels/music_provider.dart';
import 'package:deep_m/src/features/viewmodels/search_song_provider.dart';
import 'package:deep_m/src/features/views/components/textfield_search.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final searchProvider = Provider.of<SearchSongProvider>(context);

    return Scaffold(
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

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
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
                                        result['title'] ?? 'Tidak Ada',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        result['channel'] ?? 'Tidak Ada',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    final musicProvider =
                                        Provider.of<MusicProvider>(
                                          context,
                                          listen: false,
                                        );

                                    musicProvider.playAudio(
                                      context,
                                      result['videoId'] ?? '',
                                      result['title'] ?? 'Tidak Ada',
                                      result['thumbnail'] ?? '',
                                      result['channel'] ?? 'Tidak Ada',
                                      result['description'] ?? 'Tidak Ada',
                                    );
                                  },
                                  icon: Icon(Icons.play_arrow),
                                ),
                              ],
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
