import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase/widgets/header.dart';
import 'package:flutter_firebase/widgets/post_video.dart';
import 'package:flutter_firebase/widgets/progress.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image/image.dart';

import 'home.dart';

class ProfileVideos extends StatefulWidget {
  //const ProfileVideos({Key key}) : super(key: key);
  final String profileId;
  ProfileVideos({this.profileId});


  @override
  _ProfileVideosState createState() => _ProfileVideosState();
}

class _ProfileVideosState extends State<ProfileVideos> {
  final String currentUserId = currentUser?.id;

  bool isLoading=false;
  bool isFollowing=false;
  int postCount=0;
  //List<Post>posts = [];
  List<PostVideo> videoPosts = [];


  int followerCount=0;
  int followingCount=0;


  buildProfileVideos(){
    if(isLoading){
      return circularProgress();
    }
    else if(videoPosts.isEmpty){
      return Container(

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset('assets/images/no_content.svg',height: 260,),
            Padding(padding: EdgeInsets.only(top: 20),
              child: Text("No posts", style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 40,fontWeight: FontWeight.bold
              ),
              ),
            )
          ],
        ),
      );
    }
    else {
      return Column(
        children: videoPosts,
      );
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        //appBar: header(context,isAppTitle: false,titleText: "Profile"),
      appBar: GradientAppBar(titleText: "Profile",isAppTitle:false),
      body: ListView(
          children: [
            buildProfileVideos()
          ],


      ),
      //backgroundColor: Colors.purpleAccent,
    );
  }

  @override
  void initState() {

    super.initState();
    getProfileVideos();
  }

  getProfileVideos()async{
    setState(() {
      isLoading = true;
    });

    QuerySnapshot snapshot = await videoRef.doc(widget.profileId).collection('userVideos').orderBy('timeStamp',descending: true).get();

     //snapshot.docs.map((e) => print('-----------'+e.toString()));
    print(snapshot.size.toString()+'----------');
    setState(() {
      isLoading=false;
      //postCount = snapshot.docs.length;
      videoPosts = snapshot.docs.map((doc) =>PostVideo.fromDocument(doc)).toList();
    });

  }

}
