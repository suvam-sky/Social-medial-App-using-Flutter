import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase/models/user.dart';
import 'package:flutter_firebase/pages/activity_feed.dart';
import 'package:flutter_firebase/pages/comments.dart';
import 'package:flutter_firebase/pages/home.dart';
import 'package:flutter_firebase/widgets/custom_widget.dart';
import 'package:flutter_firebase/widgets/progress.dart';

class Post extends StatefulWidget {
  //const Post({Key key}) : super(key: key);
  final String postId;
  final String ownerId;
  final String username;
  final String location;
  final String description;
  final String mediaUrl;
  final dynamic likes;

  Post({
    this.username,this.postId,
    this.location,this.description,
    this.mediaUrl,this.likes,this.ownerId
});

  factory Post.fromDocument(DocumentSnapshot doc){
    return Post(
      postId: doc['postId'],
      ownerId: doc['ownerId'],
      username: doc['username'],
      location: doc['location'],
      description: doc['description'],
      mediaUrl: doc['mediaUrl'],
      likes: doc['likes'],
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
  _PostState createState() => _PostState(
      postId: this.postId,ownerId: this.ownerId,
      username: this.username,location: this.location,
      mediaUrl: this.mediaUrl,likes: this.likes,
      likeCount: getLikeCount(this.likes),description: this.description
  );
}

class _PostState extends State<Post> {
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

  _PostState({
    this.username,this.postId,this.location,this.description,
    this.mediaUrl,this.likes,this.ownerId, this.likeCount
  });


  buildPostHeader(){
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
                user.username,style: TextStyle(
                  color: Colors.black,fontWeight: FontWeight.bold
              ),
              ),
            ),
            subtitle: Text(location),
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
      postRef.doc(ownerId).collection("userPosts").doc(postId)
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
      postRef.doc(ownerId).collection("userPosts").doc(postId)
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


  buildPostImage(){
    return GestureDetector(
      onDoubleTap: handleLikePost ,
      child: Stack(
        alignment: Alignment.center,
        children: [
          cachedNetWorkImage(mediaUrl)
        ],
      ),

    );
  }


  buildPostFooter(){
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
              child: Text(
                "$description",
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
      children: <Widget>[
        buildPostHeader(),
        buildPostImage(),
        buildPostFooter()
      ],
    );
  }
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
