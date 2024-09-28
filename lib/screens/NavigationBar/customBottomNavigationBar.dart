import 'package:flutter/material.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomBottomNavigationBar({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const iconList = <IconData>[
      Icons.calendar_today,
      Icons.list,
      Icons.emoji_events,
      Icons.settings,
    ];

    return AnimatedBottomNavigationBar(
      icons: iconList,
      activeIndex: selectedIndex,
      gapLocation: GapLocation.center,
      notchSmoothness: NotchSmoothness.smoothEdge,
      leftCornerRadius: 32,
      rightCornerRadius: 32,
      activeColor: Colors.blue,
      inactiveColor: Colors.grey,
      onTap: onItemTapped,
    );
  }
}
