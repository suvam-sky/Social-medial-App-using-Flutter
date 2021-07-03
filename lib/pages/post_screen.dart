import 'package:flutter/material.dart';
import 'package:flutter_firebase/pages/home.dart';
import 'package:flutter_firebase/widgets/header.dart';
import 'package:flutter_firebase/widgets/post.dart';
import 'package:flutter_firebase/widgets/progress.dart';

class PostScreen extends StatelessWidget {
  //const PostScreen({Key key}) : super(key: key);
  final String userId;
  final String postId;
  PostScreen({
    this.userId,this.postId
});


  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: postRef.doc(userId).collection('userPosts').doc(postId).get(),
        builder: (context,snapshot){
          if(!snapshot.hasData){
            return circularProgress();
          }
          Post post = Post.fromDocument(snapshot.data);
          return Center(
              child: Scaffold(
                appBar: header(context,titleText: post.description),
                body: ListView(

                  children: [
                    Container(
                      child: post ,
                    )
                  ],
                ),
              ),
          );
        }
    );
  }
}
