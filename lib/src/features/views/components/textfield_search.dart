import 'package:deep_m/src/features/viewmodels/search_song_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TextfieldSearch extends StatefulWidget {
  const TextfieldSearch({super.key});

  @override
  State<TextfieldSearch> createState() => _TextfieldSearchState();
}

class _TextfieldSearchState extends State<TextfieldSearch> {
  @override
  Widget build(BuildContext context) {
    final searchProvider = Provider.of<SearchSongProvider>(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height / 10,
      ),
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: Colors.black),
        borderRadius: BorderRadius.circular(10),
        color: Colors.transparent,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              cursorColor: Colors.black,
              autocorrect: false,
              decoration: InputDecoration(
                hintText: "Search song here...",
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(8),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                searchProvider.searchVideos(
                  searchProvider.searchController.text,
                );
              });
            },
            child: Icon(Icons.search, size: 20),
          ),
          const SizedBox(width: 10),
        ],
      ),
    );
  }
}
