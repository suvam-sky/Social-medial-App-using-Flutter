import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase/models/user.dart';
import 'package:flutter_firebase/pages/home.dart';
import 'package:flutter_firebase/widgets/progress.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class Upload extends StatefulWidget {
  final User currentUser;

  Upload({this.currentUser});

  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> {

  final picker = ImagePicker();
  File file;
  File _image;
  bool isUploading=false;
  String postId = Uuid().v4();
  TextEditingController locationController = TextEditingController();
  TextEditingController captionController = TextEditingController();


  handleTakePhoto() async{
    Navigator.pop(context);
    // ignore: invalid_use_of_visible_for_testing_member
    PickedFile file =await picker.getImage(source: ImageSource.camera, maxHeight: 675,maxWidth: 960);
                             // here we can choose video also ****************



    setState(() {
      //this.file=file as File;
      if(file!=null){
        _image = File(file.path);
      }
      else {
        print('No image selected.');
      }

    });

  }


  handleTakePhotoFromGallery()async{
    Navigator.pop(context);
    // ignore: invalid_use_of_visible_for_testing_member
    PickedFile file =await  ImagePicker.platform.pickImage(source: ImageSource.gallery, maxHeight: 675,maxWidth: 960);
    //ImagePicker.platform.pickImage(source: source)
    setState(() {
      //this.file=file as File;
      if(file!=null){
        _image = File(file.path);
      }
      else {
        print('No image selected.');
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
              Text("Photo With camera"),
                onPressed: handleTakePhoto,
              ),
              SimpleDialogOption(child:
              Text("Image from Gallery"),
                onPressed: handleTakePhotoFromGallery,
              ),
              SimpleDialogOption(child:
              Text("Cancel"),
                onPressed: ()=>Navigator.pop(context),
              ),
            ],
          );
        });
  }



  Container buildSplashScreen(){
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
            child: Text("Upload Image", style: TextStyle(
              color: Colors.white,
              fontSize: 22
            ),
            ),
            color: Colors.deepOrange,
            onPressed: ()=> selectImage(context),
          ),
          ),
          Padding(padding: EdgeInsets.only(top: 20),
            child: RaisedButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0)
              ),
              child: Text("Upload Videos", style: TextStyle(
                  color: Colors.white,
                  fontSize: 22
              ),
              ),
              color: Colors.deepOrange,
              onPressed: ()=> selectImage(context),
            ),
          ),
        ],
      ),
    );
  }


  clearImage(){
    setState(() {
      _image = null;
    });
  }

  Future<String> uploadImage(imageFile) async{
    TaskSnapshot uploadTask  = await storageRef.child("post_$postId.jpg").putFile(imageFile).whenComplete(() async{
      storageRef.getDownloadURL().then((value) {
        return value;
      });
    });

    String downloadUrl = await uploadTask.ref.getDownloadURL();
    //print(downloadUrl);
    return downloadUrl;
  }

  createPostInFirestore({String mediaUrl,String location,String description}){

    postRef.doc(widget.currentUser.id)
        .collection("userPosts")
        .doc(postId)
        .set({
      "postId":postId,
      "ownerId":widget.currentUser.id,
      "username":widget.currentUser.username,
      "mediaUrl":mediaUrl,
      "description":description,
      "location":location,
      "timeStamp":timestamp,
      "likes":{}
    });

    globalPosts.doc(widget.currentUser.id).set({
      "postId":postId,
      "ownerId":widget.currentUser.id,
      "username":widget.currentUser.username,
      "mediaUrl":mediaUrl,
      "description":description,
      "location":location,
      "timeStamp":timestamp,
      "likes":{}
    });

}

  handleSubmit() async{
    setState(() {
      isUploading =true;
    });
   String mediaUrl = await uploadImage(_image);
   createPostInFirestore(mediaUrl: mediaUrl,location: locationController.text,description: captionController.text);

   captionController.clear();
   locationController.clear();
   setState(() {
     _image=null;
     isUploading=false;
     postId=Uuid().v4();
   });

  }

  getUserLocation()async{

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high,forceAndroidLocationManager: true);
    List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude
    );
    Placemark placemark = placemarks[0];
    String formattedAddress = "${placemark.locality},${placemark.country}";
    print("--------------"+formattedAddress);
    locationController.text = formattedAddress;
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
         FlatButton(onPressed: isUploading? null : ()=>handleSubmit() ,
             child: Text("Posts",
             style: TextStyle(color: Colors.blue,fontWeight: FontWeight.bold,fontSize: 20),
             ))
       ],
     ),
     body: ListView(
       children: [
         isUploading ? linearProgress() : Text(""),
         Container(
           height: 220,
           width: MediaQuery.of(context).size.width * 0.8,
           child: Center(
             child: AspectRatio(
               aspectRatio: 16/9,
               child: Container(
                 decoration: BoxDecoration(
                   image: DecorationImage(
                     fit: BoxFit.cover,
                     image: FileImage(_image)
                   )
                 ),
               ),
             ),
           ),
         ),
         Padding(padding: EdgeInsets.only(top: 10)),
         ListTile(
           leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(widget.currentUser.photoUrl),

           ),
           title: Container(
             width: 250,
             child: TextField(
               controller: captionController,
               decoration:InputDecoration(
                 hintText: "Write a Caption",
                 border: InputBorder.none
               ) ,
             ),
           ),
         ),
         Divider(),
          ListTile(
            leading: Icon(Icons.pin_drop,color: Colors.orange,size: 35,),
            title: Container(
              width: 250,
              child: TextField(
                controller: locationController,
                decoration: InputDecoration(
                  hintText: "Where was this photo..",
                  border: InputBorder.none
                ),
              ),
            ),

          ),
         Container(
           width: 200,
           height: 100,
           alignment: Alignment.center,
           child: RaisedButton.icon(
             onPressed: getUserLocation,
           label: Text("Use current Location",),
           shape: RoundedRectangleBorder(
             borderRadius: BorderRadius.circular(30),
           ),
             icon: Icon(Icons.my_location),
           ),
         )
       ],
     ),
   );
  }

  @override
  Widget build(BuildContext context) {
    return _image == null ? buildSplashScreen() : buildUploadForm();
  }
}