import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase/models/user.dart';
import 'package:flutter_firebase/pages/activity_feed.dart';
import 'package:flutter_firebase/pages/comments.dart';
import 'package:flutter_firebase/pages/home.dart';
import 'package:video_player/video_player.dart';

class PostVideo extends StatefulWidget {
  //const PostVideo({Key key}) : super(key: key);
  final String postId;
  final String ownerId;
  final String username;
  final String location;
  final String description;
  final String mediaUrl;
  final dynamic likes;

  PostVideo({
    this.username,this.postId,
    this.location,this.description,
    this.mediaUrl,this.likes,this.ownerId
});


  factory PostVideo.fromDocument(DocumentSnapshot doc){
    return PostVideo(
      postId: doc.data()['postId'],
      ownerId: doc.data()['ownerId'],
      username: doc.data()['username'],
      location: doc.data()['location'],
      description: doc.data()['description'],
      mediaUrl: doc.data()['mediaUrl'],
      likes: doc.data()['likes'],
    );
  }

  int getLikeCount(likes){
    //if no likes,return 0
    if(likes==0){
      return 0;
    }
    int count=0;
    likes.values.forEach( (val){
      if(val==true){
        count+=1;
      }
    });
    return count;

  }



  @override
  _PostVideoState createState() => _PostVideoState(
      postId: this.postId,ownerId: this.ownerId,
      username: this.username,location: this.location,
      mediaUrl: this.mediaUrl,likes: this.likes,
      likeCount: getLikeCount(this.likes),description: this.description
  );
}

class _PostVideoState extends State<PostVideo> {
  final String postId;
  final String ownerId;
  final String username;
  final String location;
  final String description;
  final String mediaUrl;
  int likeCount;
  Map likes;
  final String currentUserId = currentUser?.id;
  bool isLiked;
  VideoPlayerController videoPlayerController;
  //Future<void>_initializeVideoPlayerFuture;
  ChewieController _chewieController;


  _PostVideoState({
    this.username,this.postId,this.location,this.description,
    this.mediaUrl,this.likes,this.ownerId, this.likeCount
});



  buildVideoHeader(){
    return FutureBuilder(
        future: userRef.doc(ownerId).get(),
        builder:  (context,snapshot){
          if(!snapshot.hasData){
            return CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.white),);
          }
          User user = User.fromDocument(snapshot.data);
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(user.photoUrl),
              backgroundColor: Colors.grey,
            ),
            title: GestureDetector(
              onTap: ()=>showProfile(context,profileId: user.id),
              child: Text(
                user.username!=null ? user.username:"Ami"
                ,style: TextStyle(
                  color: Colors.black,fontWeight: FontWeight.bold
              ),
              ),
            ),
            //subtitle: Text(location),
            trailing: IconButton(
              onPressed: ()=> print("deleting post"),
              icon: Icon(Icons.more_vert),
            ),
          );
        }
    );
  }

  handleLikePost(){
    bool _isLiked = likes[currentUserId]==true;

    if(_isLiked){
      videoRef.doc(ownerId).collection("userVideos").doc(postId)
          .update({
        'likes.$currentUserId':false
      });

      removeLikeFromActivityFeed();
      setState(() {
        likeCount-=1;
        isLiked = false;
        likes[currentUserId]=false;
      });

    }
    else if(!_isLiked){
      videoRef.doc(ownerId).collection("userVideos").doc(postId)
          .update({
        'likes.$currentUserId':true
      });

      addLikeToActivityFeed();
      setState(() {
        likeCount+=1;
        isLiked = true;
        likes[currentUserId]=true;
      });
    }

  }

  addLikeToActivityFeed(){
    bool isNotPostOwner = currentUserId !=ownerId;
    if(isNotPostOwner){
      activityFeddRef.doc(ownerId).collection("feedItems")
          .doc(postId).set({
        "type":"like",
        "username":currentUser.username,
        "userId":currentUser.id,
        "userProfileImg" : currentUser.photoUrl,
        "postId":postId,
        "mediaUrl":mediaUrl,
        "timestamp":timestamp
      });
    }
  }

  removeLikeFromActivityFeed(){
    bool isNotPostOwner = currentUserId !=ownerId;

    if(isNotPostOwner){
      activityFeddRef.doc(ownerId).collection("feedItems")
          .doc(postId).get().then((doc) {
        if(doc.exists){
          doc.reference.delete();
        }
      });
    }

  }

    buildVideo(){
    return GestureDetector(
      onDoubleTap: handleLikePost,
      child: Container(
        height: MediaQuery.of(context).size.height/2.7,
        width: MediaQuery.of(context).size.width,
        child: Chewie(
              //key: PageStorageKey(mediaUrl),
              controller: _chewieController

        ),
      ),
    );
  }
  buildVideoFooter(){
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(padding: EdgeInsets.only(top: 40,left: 20)),
            GestureDetector(
              onTap:handleLikePost,
              child: Icon(
                isLiked?Icons.favorite :Icons.favorite_border,
                size: 28,color: Colors.pink,),
            ),
            Padding(padding: EdgeInsets.only(top: 40,right: 20)),
            GestureDetector(
              onTap:()=> showComments(context,postId: postId,ownerId: ownerId,mediaUrl: mediaUrl),
              child: Icon(Icons.chat,size: 28,color: Colors.blueAccent,),
            ),

          ],
        ),
        Row(
          children: [
            Container(
              margin: EdgeInsets.only(left: 20),
              child: Text(
                "$likeCount likes",
                style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(left: 20),
              child: Text( description!=null?
                "$description": "I give this description",
                style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),
              ),
            ),
            // Expanded(
            //   child: Text(description),
            // )
          ],
        ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    isLiked = (likes[currentUserId]==true);
    return Column(

      mainAxisSize: MainAxisSize.min,
      //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        buildVideoHeader(),
        buildVideo(),
        buildVideoFooter()
      ],
    );
  }
  @override
  void initState() {
    super.initState();
    // videoPlayerController = VideoPlayerController.network(mediaUrl);
    // _initializeVideoPlayerFuture = videoPlayerController.initialize().then((_) {
    //
    //   setState(() {
    //
    //   });
    // });
    _chewieController = ChewieController(
        videoPlayerController: VideoPlayerController.network(mediaUrl),
      aspectRatio:  16/9,
      autoInitialize: true,
      // autoPlay: true,
      // looping: true,
      errorBuilder: (context,errorMessage){
          return Text(errorMessage,style: TextStyle(color: Colors.black),);
      }

    );


  }
  @override
  void dispose() {

    super.dispose();
    videoPlayerController.dispose();
    _chewieController.dispose();
    //_chewieController.videoPlayerController.dispose();
  }

  // getVideos()async{
  //   setState(() {
  //
  //   });
  //
  //   QuerySnapshot snapshot = await videoRef.doc(widget.ownerId).collection('userVideos').orderBy('timeStamp',descending: true).get();
  //
  // }

}
showComments(BuildContext context,{String postId,String ownerId,String mediaUrl}){

  Navigator.push(context,MaterialPageRoute(builder:(context){
    return Comments(
      postId: postId,
      postOwnerId: ownerId,
      postMediaUrl: mediaUrl,
    );
  })

  );
}