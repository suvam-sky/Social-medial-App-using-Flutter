import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase/pages/activity_feed.dart';
import 'package:flutter_firebase/pages/profile.dart';
import 'package:flutter_firebase/pages/search.dart';
import 'package:flutter_firebase/pages/timeline.dart';
import 'package:flutter_firebase/pages/upload.dart';
import 'package:flutter_firebase/widgets/drawer_widget.dart';
import 'package:provider/provider.dart';
import 'google_sign_in.dart';


class LoggedInWidget extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    PageController pageController;
    int pageIndex=0;



    return Scaffold(
      appBar: AppBar(title: Text("Welcome"),),
      body: PageView(
        children: <Widget>[
          Timeline(),
          ActivityFeed(),
          Upload(),
          Search(),
          Profile()

        ],
        controller: pageController,
        onPageChanged: onPageChanged(0),
        physics:NeverScrollableScrollPhysics() ,
      ),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: pageIndex,

      ),
      drawer: DrawerWidget(),
    );

  }

  onPageChanged(int pageIndex){
    pageIndex=pageIndex;
  }



}