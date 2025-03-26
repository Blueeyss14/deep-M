import 'package:deep_m/src/features/viewmodels/search_song_provider.dart';
import 'package:deep_m/src/shared/style/custom_color.dart';
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
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height / 10,
      ),
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: Colors.transparent),
        borderRadius: BorderRadius.circular(6),
        color: CustomColor.white1,
      ),
      child: Row(
        children: [
          const SizedBox(width: 5),
          Expanded(
            child: TextField(
              controller: searchProvider.searchController,
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
              searchProvider.searchVideos(searchProvider.searchController.text);
            },
            child: Icon(Icons.search, size: 20),
          ),
          const SizedBox(width: 10),
        ],
      ),
    );
  }
}
