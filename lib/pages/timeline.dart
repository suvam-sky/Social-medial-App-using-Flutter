import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:flutter_firebase/models/user.dart';
import 'package:flutter_firebase/widgets/custom_widget.dart';
import 'package:flutter_firebase/widgets/drawer_widget.dart';
import 'package:flutter_firebase/widgets/header.dart';
import 'package:flutter_firebase/widgets/post.dart';
import 'package:flutter_firebase/widgets/progress.dart';
import 'package:flutter_svg/svg.dart';

import 'activity_feed.dart';
import 'comments.dart';
import 'home.dart';

class Timeline extends StatefulWidget {


  // factory Timeline.fromDocument(DocumentSnapshot doc){
  //   return Timeline(
  //     postId: doc['postId'],
  //     ownerId: doc['ownerId'],
  //     username: doc['username'],
  //     location: doc['location'],
  //     description: doc['description'],
  //     mediaUrl: doc['mediaUrl'],
  //     likes: doc['likes'],
  //   );
  // }

  // int getLikeCount(likes){
  //   //if no likes,return 0
  //   if(likes==0){
  //     return 0;
  //   }
  //   int count=0;
  //   likes.values.forEach( (val){
  //     if(val==true){
  //       count+=1;
  //     }
  //   });
  //   return count;
  //
  // }

  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {

  final String currentUserId = currentUser?.id;

  bool isLoading=false;
  bool isFollowing=false;
  List<Post>posts = [];

  buildProfilePost(){
    if(isLoading){
      return circularProgress();
    }
    else if(posts.isEmpty){
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
    else{
      return Column(
        children: posts,
      );
    }
    
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getProfilePosts();

  }


  @override
  Widget build(BuildContext context) {
   // isLiked = (likes[currentUserId]==true);

    return Scaffold(
      appBar: header(context,isAppTitle: false,titleText: "Timeline"),
      
      body: buildProfilePost(),
      
      drawer: DrawerWidget(),
    );
  }




  getProfilePosts()async{

    setState(() {
      isLoading = true;
    });
    QuerySnapshot snapshot = await globalPosts.orderBy('timeStamp',descending: true).get();
    
    // QuerySnapshot snapshot =  await postRef.doc(widget.profileId).collection('userPosts')
    //     .orderBy('timeStamp',descending: true).get();

    setState(() {
      isLoading=false;
      posts = snapshot.docs.map((doc) =>Post.fromDocument(doc)).toList();
    });
  }



}


