import 'package:deep_m/src/features/views/components/textfield_search.dart';
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
        child: TextfieldSearch(),
      ),
    );
  }
}
