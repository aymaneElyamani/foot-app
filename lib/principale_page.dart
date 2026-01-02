import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';

import 'package:app010/screens/competitions.dart';
import 'package:app010/screens/equipe_classement.dart';
import 'package:app010/screens/home.dart';
import 'package:app010/screens/matchs.dart';
import 'package:app010/widgets/app_drawer.dart';
import 'package:app010/colors.dart' as app_colors;

class Principalpage extends StatefulWidget {
  const Principalpage({super.key});

  @override
  State<Principalpage> createState() => _PrincipalpageState();
}

class _PrincipalpageState extends State<Principalpage> {
  int _page = 0;
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  void _changePage(int index) {
    setState(() {
      _page = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final primary = Color(app_colors.primary);
    final secondary = Color(app_colors.secondary);

    return Scaffold(
      bottomNavigationBar: CurvedNavigationBar(
        key: _bottomNavigationKey,
        index: _page,
        items: <Widget>[
          Icon(Icons.person, size: 30, color: primary),
          Icon(Icons.emoji_events, size: 30, color: primary),
          Icon(Icons.sports_soccer, size: 30, color: primary),
          Icon(Icons.leaderboard, size: 30, color: primary),
        ],
        color: Colors.white,
        buttonBackgroundColor: secondary,
        backgroundColor: primary,
        animationCurve: Curves.easeInOut,
        animationDuration: Duration(milliseconds: 600),
        onTap: (index) {
          setState(() {
            _page = index;
          });
        },
        letIndexChange: (index) => true,
      ),
      body: IndexedStack(
        index: _page,
        children: [
          HomePage(onPageChange: _changePage),
          CompetitionsPage(onPageChange: _changePage),
          MatchsPage(onPageChange: _changePage),
          ClassementPage(onPageChange: _changePage),
        ],
      ),
    );
  }
}
