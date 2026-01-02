import 'package:flutter/material.dart';
import 'package:app010/colors.dart' as app_colors;

class AppDrawer extends StatelessWidget {
  final Function(int) onPageSelected;

  const AppDrawer({super.key, required this.onPageSelected});

  @override
  Widget build(BuildContext context) {
    final primary = Color(app_colors.primary);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: primary),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.sports_soccer, size: 48, color: Colors.white),
                SizedBox(height: 8),
                Text(
                  'Football App',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.person, color: primary),
            title: const Text('Profil'),
            onTap: () {
              Navigator.pop(context);
              onPageSelected(0);
            },
          ),
          ListTile(
            leading: Icon(Icons.emoji_events, color: primary),
            title: const Text('Compétitions'),
            onTap: () {
              Navigator.pop(context);
              onPageSelected(1);
            },
          ),
          ListTile(
            leading: Icon(Icons.sports_soccer, color: primary),
            title: const Text('Matchs'),
            onTap: () {
              Navigator.pop(context);
              onPageSelected(2);
            },
          ),
          ListTile(
            leading: Icon(Icons.leaderboard, color: primary),
            title: const Text('Classement'),
            onTap: () {
              Navigator.pop(context);
              onPageSelected(3);
            },
          ),
        ],
      ),
    );
  }
}
