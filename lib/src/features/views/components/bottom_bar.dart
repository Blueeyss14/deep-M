import 'package:deep_m/src/features/viewmodels/bottombar_viemodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BottomBar extends StatefulWidget {
  const BottomBar({super.key});

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  @override
  Widget build(BuildContext context) {
    final bottomNavItem = Provider.of<BottombarViemodel>(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.black.withAlpha(10), Colors.black.withAlpha(1000)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(
          bottomNavItem.bottomBarItem.length,
          (i) => Expanded(
            child: GestureDetector(
              onTap: () => bottomNavItem.pageIndex(i),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                color: Colors.transparent,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(bottomNavItem.bottomBarItem[i].icon.icon, size: 25),
                    Text(
                      bottomNavItem.bottomBarItem[i].title,
                      style: TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
