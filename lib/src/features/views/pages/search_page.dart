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
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextfieldSearch(),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: searchProvider.searchResult.length,
                itemBuilder: (context, index) {
                  final result = searchProvider.searchResult[index];
                  return Text(result['title'] ?? 'Tidak Ada');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
