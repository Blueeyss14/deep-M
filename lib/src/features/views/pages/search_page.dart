import 'package:flutter/material.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
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
            Icon(Icons.search, size: 20),
            const SizedBox(width: 10),
          ],
        ),
      ),
    );
  }
}
