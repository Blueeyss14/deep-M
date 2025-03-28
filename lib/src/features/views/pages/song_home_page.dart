import 'package:flutter/material.dart';

class SongHomePage extends StatelessWidget {
  const SongHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /// ini-------------------------------------------COVER--------------------------------------
              Container(
                height: MediaQuery.of(context).size.height / 2 - 50,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  color: Colors.grey[400],
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.asset("images/test.png", fit: BoxFit.cover),
              ),
              const SizedBox(height: 10),
              Text(
                "--------- Song Title ---------",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  color: Colors.grey[400],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Icon(Icons.skip_previous),
                    Icon(Icons.play_arrow),
                    Icon(Icons.skip_next),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
