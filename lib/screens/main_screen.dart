import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/providers/auth/auth_provider.dart';
import 'package:instagram_clone/screens/feed_screen.dart';
import 'package:instagram_clone/screens/feed_upload_screen.dart';
import 'package:provider/provider.dart';

import '../utils/logger.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 5, vsync: this);
  }

  void bottomNavigationItemOnTab(int index){
    setState(() {
      tabController.index = index;
    });
  }

  @override
  void dispose() {
    super.dispose();
    // TODO: implement dispose
    tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: TabBarView(
          controller: tabController,
          physics: NeverScrollableScrollPhysics(),
          children: [
            FeedScreen(),
            Center(child: Text('2'),),
            FeedUploadScreen(
              onFeedUploaded: () {
                setState(() {
                  tabController.index = 0;
                });
              },
            ),
            Center(child: Text('4'),),
            Center(child: Text('5'),),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
            currentIndex: tabController.index,
            onTap: bottomNavigationItemOnTab,
            showSelectedLabels: false,
            showUnselectedLabels: false,
      
          items: [BottomNavigationBarItem(icon: Icon(Icons.home),
            label: 'feed',),
            BottomNavigationBarItem(icon: Icon(Icons.search),
              label: 'search',),
            BottomNavigationBarItem(icon: Icon(Icons.add_circle),
              label: 'upload',),
            BottomNavigationBarItem(icon: Icon(Icons.favorite),
              label: 'favorite',),
            BottomNavigationBarItem(icon: Icon(Icons.person),
              label: 'profile',),
          ]
        ),
      ),
    );
  }
}
