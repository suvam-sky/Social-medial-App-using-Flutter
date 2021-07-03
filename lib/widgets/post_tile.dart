import 'package:flutter/material.dart';
import 'package:flutter_firebase/pages/post_screen.dart';
import 'package:flutter_firebase/widgets/custom_widget.dart';
import 'package:flutter_firebase/widgets/post.dart';

class PostTile extends StatelessWidget {
  //const PostTile({Key key}) : super(key: key);
  final Post post;

  PostTile(this.post);

  showPost(context){
    Navigator.push(context,
        MaterialPageRoute(builder: (context)=>PostScreen(postId: post.postId,userId: post.ownerId,))
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ()=>showPost(context) ,
      child: cachedNetWorkImage(post.mediaUrl),
    );
  }
}


