import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase/models/user.dart';
import 'package:flutter_firebase/pages/activity_feed.dart';
import 'package:flutter_firebase/pages/demo_video_upload.dart';
import 'package:flutter_firebase/pages/profile.dart';
import 'package:flutter_firebase/pages/profile_videos.dart';
import 'package:flutter_firebase/pages/search.dart';
import 'package:flutter_firebase/pages/timeline.dart';
import 'package:flutter_firebase/pages/upload.dart';
import 'package:flutter_firebase/widgets/post_video.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'create_account.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();
CollectionReference userRef = FirebaseFirestore.instance.collection('users');
CollectionReference postRef = FirebaseFirestore.instance.collection('posts');
CollectionReference globalPosts = FirebaseFirestore.instance.collection('globalPosts');
CollectionReference videoRef = FirebaseFirestore.instance.collection('videoPosts');
CollectionReference commentsRef = FirebaseFirestore.instance.collection('comments');
CollectionReference activityFeddRef = FirebaseFirestore.instance.collection('feed');
CollectionReference followingRef = FirebaseFirestore.instance.collection('following');
CollectionReference followersRef = FirebaseFirestore.instance.collection('followers');

final  storageRef =  FirebaseStorage.instance.ref();

final timestamp = DateTime.now();
User currentUser;


class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isAuth=false;
  PageController pageController;
  int pageIndex=0;


  login(){
    googleSignIn.signIn();
  }

  logout(){
    googleSignIn.signOut();
  }

  onPageChange(int pageIndex){
    setState(() {
      this.pageIndex=pageIndex;
    });
  }
  onTap(int pageIndex){
    pageController.animateToPage(pageIndex,
        duration: Duration(microseconds: 300),
        curve: Curves.easeInOut
    );
  }

  Widget buildAuthScreen(){
    return Scaffold(
      body: PageView(
        children: <Widget>[
           //Timeline(),
          VideoUpload(currentUser: currentUser),
          // ElevatedButton(
          //   child: Text('Logout'),
          //   onPressed: logout,
          // ),
          ActivityFeed(),
          Upload(currentUser:currentUser),
           //Search(),
          ProfileVideos(profileId: currentUser?.id),
          Profile(profileId: currentUser?.id,)
        ],
        controller: pageController,
        onPageChanged: onPageChange,
        physics: NeverScrollableScrollPhysics(),

      ),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: pageIndex,
        onTap: onTap,
        activeColor: Theme.of(context).primaryColor,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.whatshot),),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_active),),
          BottomNavigationBarItem(icon: Icon(Icons.photo_camera,size: 35.0,),),
          BottomNavigationBarItem(icon: Icon(Icons.search),),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle ),),
        ],
      ),
    );

    // return RaisedButton(
    //   child: Text('Logout'),
    //   onPressed: logout,
    // );
  }

  Scaffold buildUnAuthScreen(){
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Colors.teal,
              Colors.purple
            ],
          ),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("Flutter Share",style: TextStyle(fontSize: 90,
                color: Colors.white),),
            GestureDetector(
              onTap: login,
              child: Container(
                width: 260,
                height: 60,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/google_signin_button.png'),
                    fit: BoxFit.cover
                  )
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    pageController = PageController();

    googleSignIn.onCurrentUserChanged.listen((account) {
      handleSignIn(account);
    },onError: (err){
      print('Error signing in: $err');
    } );

    //Reauthenticate user when the app is open again
    googleSignIn.signInSilently(suppressErrors: false).then((account) => {
    handleSignIn(account)
    }).catchError((err){
      print('Error signing in: $err');
    });

  }

  handleSignIn(GoogleSignInAccount account){
    if(account!=null){

      createUserInFireStore();

      setState(() {
       // print('user signed in: $account');
        isAuth = true;
      });
    }
    else{
      setState(() {
        isAuth = false;
      });
    }
  }

  createUserInFireStore() async {
    //1)check if user exists in users collection in database(according to their ID)
    final GoogleSignInAccount  user = googleSignIn.currentUser;
    DocumentSnapshot doc = await userRef.doc(user.id).get();

    //2)if the uer does not exists , then take them to the create account page

    if(!doc.exists){
      // final username = Navigator.push(context, MaterialPageRoute(builder: (context)=>
      //   CreateAccount()
      // ));


      Map<String,dynamic>data ={
          "id": user.id,
          "username": user.displayName ,
          "photoUrl" : user.photoUrl,
          "email" : user.email,
          "displayName" : user.displayName,
          "bio" : "",
          "timestamp":timestamp
      };

      userRef.doc(doc.id).set(data);

     //userRef.add(data);
     //  userRef.doc(user.id).set({
     //    "id": user.id,
     //    "username": username ,
     //    "photoUrl" : user.photoUrl,
     //    "email" : user.email,
     //    "displayName" : user.displayName,
     //    "bio" : "",
     //    "timestamp":timestamp
     //  });


      doc = await userRef.doc(user.id).get();
    }
    //3)get the username from create account, use it to mke the new user document in user collection


    currentUser = User.fromDocument(doc);
    //print(currentUser);
    //print(currentUser.displayName);

  }

  @override
  void dispose() {
    // TODO: implement dispose
    pageController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return isAuth ? buildAuthScreen() : buildUnAuthScreen();
  }
}