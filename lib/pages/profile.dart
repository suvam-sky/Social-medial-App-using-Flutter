import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase/models/user.dart';
import 'package:flutter_firebase/pages/edit_profile.dart';
import 'package:flutter_firebase/pages/home.dart';
import 'package:flutter_firebase/widgets/header.dart';
import 'package:flutter_firebase/widgets/post.dart';
import 'package:flutter_firebase/widgets/post_tile.dart';
import 'package:flutter_firebase/widgets/post_video.dart';
import 'package:flutter_firebase/widgets/progress.dart';
import 'package:flutter_svg/svg.dart';

class Profile extends StatefulWidget {
  final String profileId;
  Profile({this.profileId});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {

  final String currentUserId = currentUser?.id;

  bool isLoading=false;
  bool isFollowing=false;
  int postCount=0;
  List<Post>posts = [];
  List<PostVideo>videoPosts=[];
  String postOrientation = "grid";

  int followerCount=0;
  int followingCount=0;


  Column buildColumnCount(String label, int count){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          count.toString(),style: TextStyle(fontSize: 22,fontWeight: FontWeight.bold),
        ),
        Container(
          margin: EdgeInsets.only(top: 4),
          child: Text(
            label,style: TextStyle(color: Colors.grey,fontSize: 15,fontWeight: FontWeight.w400),
          ),
        )
      ],
    );

  }


  editProfile(){
    Navigator.push(context,MaterialPageRoute(builder: (context)=>
    EditProfile(currentUserId : currentUserId)
    ) );
  }

  Container buildButton({String text,Function function}){
      return Container(
        padding: EdgeInsets.only(top: 2),
        child: TextButton(
          onPressed: function,
          child: Container(
            width: 250,
            height: 27,
            child: Text(
              text,style: TextStyle(
                color:isFollowing ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold ),
            ),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isFollowing? Colors.white : Colors.blue,
              border: Border.all(color:isFollowing? Colors.grey: Colors.blue),
              borderRadius: BorderRadius.circular(5)
            ),
          ),
        ),
      );
  }


  buildProfileButton(){
    // viewing your own profile-- should show edit profile button
    bool isProfileOwner = currentUserId == widget.profileId;

    if(isProfileOwner){
      return buildButton(text: "Edit Profile",function: editProfile);
    }
    else if(isFollowing){
      return buildButton(text: "Unfollow",function: handleUnfollowUser);
    }
    else if(!isFollowing){
      return  buildButton(text :"Follow",function: handleFollowUser);
    }


  }

  handleUnfollowUser(){
    setState(() {
      isFollowing=false;
    });
    //remove followers
    followersRef.doc(widget.profileId).collection('userFollowers')
        .doc(currentUserId)
        .get()
        .then((doc){
          if(doc.exists){
            doc.reference.delete();
          }
    });

    // remove following
    followingRef.doc(currentUserId).collection('userFollowing')
        .doc(widget.profileId)
        .get()
        .then((doc){
          if(doc.exists){
            doc.reference.delete();
          }
    });

    // delete activity feed item
    activityFeddRef.doc(widget.profileId)
        .collection('feedItems')
        .doc(currentUserId)
        .get()
        .then((doc){
            if(doc.exists){
              doc.reference.delete();
            }
    });

  }

  handleFollowUser(){
    setState(() {
      isFollowing=true;
    });
    //make auth-user follower of another user(update THEIR followers collection)
    followersRef.doc(widget.profileId).collection('userFollowers')
      .doc(currentUserId).set({

    });

    // put that user on your following collection(update your following collection)
    followingRef.doc(currentUserId).collection('userFollowing')
      .doc(widget.profileId).set({

    });

    // add activity feed item for that user to notify about new followers
    activityFeddRef.doc(widget.profileId).collection('feedItems')
      .doc(currentUserId).set({
      "type": "follow",
      "ownerId":widget.profileId,
      "userId" : currentUserId,
      "userProfileImg":currentUser.photoUrl,
      "timestamp":timestamp
    });

  }



  buildProfileHeader(){
    return FutureBuilder(
        future: userRef.doc(widget.profileId).get(),
        builder: (context,snapshot){
          if(!snapshot.hasData){
            return circularProgress();
          }
          User user =User.fromDocument(snapshot.data);
          return Padding(padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.grey,
                      backgroundImage: CachedNetworkImageProvider(user.photoUrl),
                    ),
                    Expanded(
                        flex: 1,
                        child: Column(
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                buildColumnCount("Posts",postCount),
                                buildColumnCount("Followers",followerCount),
                                buildColumnCount("Following",followingCount),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                buildProfileButton()
                              ],
                            )
                          ],
                        )
                    )
                  ],
            ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(top: 12),
                  child: Text(
                    user.username,
                    style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(top: 4),
                  child: Text(
                    user.displayName,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(top: 4),
                  child: Text(
                    user.bio,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          );
        }

    );
  }

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

    else if(postOrientation=="grid") {
      List<GridTile> gridTiles = [];
      posts.forEach((post) {
        gridTiles.add(GridTile(child: PostTile(post)));
      });
      return GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        mainAxisSpacing: 1.5,
        crossAxisSpacing: 1.5,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: gridTiles,
      );
    }
    else if(postOrientation=="list"){
      return Column(
        children: posts,
      );
    }

  }

  setPostOrientation(String postOrientation){
    setState(() {
      this.postOrientation=postOrientation;
    });
  }


  buildTogglePostOrientation(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
            icon: Icon(Icons.grid_on),
            color: postOrientation=="grid"? Theme.of(context).primaryColor :Colors.grey,
            onPressed: ()=>setPostOrientation("grid")
        ),
        IconButton(
            icon: Icon(Icons.list),
            color: postOrientation=="list"?Theme.of(context).primaryColor: Colors.grey,
            onPressed:()=> setPostOrientation("list")
        ),
      ],
    );
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: header(context,isAppTitle: false,titleText: "Profile"),
      appBar: GradientAppBar(titleText: "Profile",isAppTitle:false),
      body: ListView(
        children: [
          buildProfileHeader(),
          Divider(),
          buildTogglePostOrientation(),
          Divider(
            height: 1.0,
          ),
          buildProfilePost(),
        ],
      ),

    );
  }


  @override
  void initState() {

    super.initState();
    getProfilePosts();

    getFollowers();
    getFollowing();
    checkIfFollowing();

  }
  checkIfFollowing() async{
    DocumentSnapshot doc =  await followersRef.doc(widget.profileId)
        .collection('userFollowers')
        .doc(currentUserId).get();
    setState(() {
      isFollowing=doc.exists;
    });
  }
  getFollowers()async{
    QuerySnapshot snapshot =  await followersRef.doc(widget.profileId)
        .collection('userFollowers')
        .get();

    setState(() {
      followerCount=snapshot.docs.length;
    });
  }
  getFollowing()async{
    QuerySnapshot snapshot = await followingRef.doc(widget.profileId)
        .collection('userFollowing').get();

    setState(() {
      followingCount=snapshot.docs.length;
    });
  }



  getProfilePosts()async{

    setState(() {
      isLoading = true;
    });
     QuerySnapshot snapshot =  await postRef.doc(widget.profileId).collection('userPosts')
        .orderBy('timeStamp',descending: true).get();
    //QuerySnapshot snapshot = await videoRef.doc(widget.profileId).collection('userVideos').orderBy('timeStamp',descending: true).get();


    setState(() {
       isLoading=false;
       postCount = snapshot.docs.length;
       posts = snapshot.docs.map((doc) =>Post.fromDocument(doc)).toList();
     });
  }


}