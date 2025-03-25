import 'package:flutter/material.dart';

class UiTest extends StatelessWidget {
  const UiTest({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              alignment: Alignment.center,
              width: double.infinity,
              color: Colors.red,
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: List.generate(4, (index) {
                  return Container(
                    color: Colors.green,
                    height: 100,
                    width: 120,
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
