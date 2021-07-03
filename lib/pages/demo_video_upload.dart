import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase/models/user.dart';
import 'package:flutter_firebase/pages/home.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:uuid/uuid.dart';

class VideoUpload extends StatefulWidget {
  final User currentUser;
  VideoUpload({this.currentUser});
  //const VideoUpload({Key key}) : super(key: key);

  @override
  _VideoUploadState createState() => _VideoUploadState();
}

class _VideoUploadState extends State<VideoUpload> {

  final picker = ImagePicker();
  File file;
  File _image;
  bool isUploading=false;
  TextEditingController captionController = TextEditingController();
  String postId = Uuid().v4();

  clearImage(){
    setState(() {
      _image = null;
    });
  }
  Future<String> uploadVideo(imageFile) async{
    // TaskSnapshot uploadTask  = await storageRef.child("post_$postId.jpg").putFile(imageFile).whenComplete(() async{
    //   storageRef.getDownloadURL().then((value) {
    //     return value;
    //   });
    // });

    TaskSnapshot uploadTask = await storageRef.child("video_$postId.mp4").putFile(imageFile,SettableMetadata(contentType: 'video/mp4')).whenComplete(() async{
      storageRef.getDownloadURL().then((value) {
        return value;
      });
    });

    String downloadUrl = await uploadTask.ref.getDownloadURL();
    //print(downloadUrl);
    return downloadUrl;
  }

  handleVideoFromGallery()async{
    Navigator.pop(context);
    // ignore: invalid_use_of_visible_for_testing_member
    PickedFile file = await ImagePicker.platform.pickVideo(source: ImageSource.gallery);
    setState(() {
      if(file!=null){
        _image= File(file.path);
      }
      else{
        print('No video selected.');
      }
    });
  }
  selectImage(parentContext){
    return showDialog(
        context: parentContext,
        builder: (context){
          return SimpleDialog(
            title: Text("Create Post"),
            children: [

              SimpleDialogOption(child:
              Text("Video from Gallery"),
                onPressed: handleVideoFromGallery,
              ),
              SimpleDialogOption(child:
              Text("Cancel"),
                onPressed: ()=>Navigator.pop(context),
              ),
            ],
          );
        });
  }


  createPostInFirestore({String mediaUrl}) {
    videoRef.doc(widget.currentUser.id)
        .collection("userVideos")
        .doc(postId)
        .set({
      "postId": postId,
      "ownerId": widget.currentUser.id,
      "username": widget.currentUser.username,
      "mediaUrl": mediaUrl,
      "timeStamp": timestamp,
      "likes": {}
    });
  }

  handleSubmit() async{
    setState(() {
      isUploading =true;
    });
    String mediaUrl = await uploadVideo(_image);
    createPostInFirestore(mediaUrl: mediaUrl);

    //captionController.clear();

    setState(() {
      _image=null;
      isUploading=false;
      postId=Uuid().v4();
    });

  }
  buildSplashScreen(){
    return Container(
      color: Theme.of(context).accentColor.withOpacity(0.6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset('assets/images/upload.svg',height: 260,),
          Padding(padding: EdgeInsets.only(top: 20),
            child: RaisedButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0)
              ),
              child: Text("Upload Video", style: TextStyle(
                  color: Colors.white,
                  fontSize: 22
              ),
              ),
              color: Colors.deepOrange,
              onPressed: ()=> selectImage(context),
            ),
          )
        ],
      ),
    );
  }

  Scaffold buildUploadForm(){
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white70,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,color: Colors.black,),
          onPressed: clearImage,
        ),
        title: Text("Caption Post",style: TextStyle(color: Colors.black),),
        actions: [
          ElevatedButton(onPressed: isUploading? null : ()=>handleSubmit() ,
              child: Text("Posts",
                style: TextStyle(color: Colors.blue,fontWeight: FontWeight.bold,fontSize: 20),
              ))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _image == null ? buildSplashScreen() : buildUploadForm();
  }
}
