import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase/pages/home.dart';
import 'package:flutter_firebase/widgets/header.dart';
import 'package:flutter_firebase/widgets/progress.dart';
import 'package:timeago/timeago.dart' as timeago;

class Comments extends StatefulWidget {
  //const Comments({Key key}) : super(key: key);
  final String postId;
  final String postOwnerId;
  final String postMediaUrl;

  Comments({
    this.postId,this.postMediaUrl,this.postOwnerId
});


  @override
  _CommentsState createState() => _CommentsState(
    postId: this.postId,
    postOwnerId: this.postOwnerId,
    postMediaUrl: this.postMediaUrl
  );
}

class _CommentsState extends State<Comments> {

  TextEditingController commentController = TextEditingController();

  final String postId;
  final String postOwnerId;
  final String postMediaUrl;

  _CommentsState({
    this.postId,this.postMediaUrl,this.postOwnerId
  });

  buildComments(){
    return StreamBuilder(
      stream: commentsRef.doc(postId).collection('comments').orderBy("timestamp",descending: false).snapshots(),
      builder: (context,snapshot){
        if(!snapshot.hasData){
          return circularProgress();
        }
          List<Comment> comments =[];
          final data = snapshot.requireData;
          return ListView.builder(
              itemCount: data.size,
              itemBuilder: (context,index){
                return Comment(data.docs[index].data(),data.docs[index].reference);
              }

          );

      },
    );
  }

  addComment(){
    commentsRef.doc(postId).collection("comments")
        .add({
      "username":currentUser.username,
      "comment" :commentController.text,
      "timestamp":timestamp,
      "avatarUrl":currentUser.photoUrl,
      "userId":currentUser.id
    });
    bool isNotPostOwner = postOwnerId!=currentUser.id;

    if(isNotPostOwner){
      activityFeddRef.doc(postOwnerId).collection('feedItems').add({
        "type":"comment",
        "commentData":commentController.text,
        "username":currentUser.username,
        "userId":currentUser.id,
        "userProfileImg" : currentUser.photoUrl,
        "postId":postId,
        "mediaUrl":postMediaUrl,
        "timestamp":timestamp
      });
    }



    commentController.clear();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context,titleText: "Comments"),
      body: Column(
        children: [
          Expanded(
              child: buildComments(),
          ),
          Divider(),
          ListTile(
            title: TextFormField(
                controller: commentController,
              decoration: InputDecoration(
                labelText: "Write a comment...."
              ),
            ),
            trailing: OutlinedButton(
              onPressed: addComment,
              //style: OutlinedButton.styleFrom(side: BorderSide.none),
              child: Text("Post"),
            ),
          )
        ],
      ),
    );
  }
}



class Comment extends StatelessWidget {
  //const Comment({Key key}) : super(key: key);
  // final String username;
  // final String userId;
  // final String avatarUrl;
  // final String comment;
  // final Timestamp timestamp;
  final DocumentReference ref;
  Map<String,dynamic>m;

  Comment(
    // this.username,
    // this.userId,
    // this.avatarUrl,
    // this.comment,this.timestamp,
    this.m,
    this.ref
);

  // factory Comment.fromDocument(DocumentSnapshot doc){
  //   return Comment(
  //     // username: doc['username'],
  //     // userId: doc['userId'],
  //     // comment: doc['comment'],
  //     // timestamp: doc['timestamp'],
  //     // avatarUrl: doc['avatarUrl'],
  //   );
  // }


  @override
  Widget build(BuildContext context) {
    return  Column(
      children: [
        ListTile(
          title: Text(m['comment']),
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(m['avatarUrl']),
          ),
          subtitle: Text(timeago.format(m['timestamp'].toDate())),
        ),
        Divider()
      ],
    );
  }
}
