import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase/logged_in_widget.dart';
import 'package:flutter_firebase/pages/activity_feed.dart';
import 'package:flutter_firebase/pages/create_account.dart';
import 'package:flutter_firebase/pages/home.dart';
import 'package:flutter_firebase/pages/profile.dart';
import 'package:flutter_firebase/pages/search.dart';
import 'package:flutter_firebase/pages/timeline.dart';
import 'package:flutter_firebase/pages/upload.dart';
import 'package:flutter_firebase/sign_up_widget.dart';
import 'package:flutter_firebase/widgets/drawer_widget.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'google_sign_in.dart';

Future main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        accentColor: Colors.teal
      ),
      home: Home(),

    );
  }
}
//
// class MyHomePage extends StatefulWidget {
//
//
//
//
//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//
//   PageController pageController;
//   int pageIndex=0;
//   final userRef = FirebaseFirestore.instance.collection('users');
//
//   final timestamp = DateTime.now();
//
//
//   onPageChange(int pageIndex){
//     setState(() {
//       this.pageIndex=pageIndex;
//     });
//   }
//   onTap(int pageIndex){
//     pageController.animateToPage(pageIndex,
//       duration: Duration(microseconds: 300),
//       curve: Curves.easeInOut
//     );
//   }
//   logout(){
//     final provider =
//     Provider.of<GoogleSignInProvider>(context, listen: false);
//     provider.logout();
//   }
//
//   Scaffold buildAuthScreen(){
//     return Scaffold(
//       body: PageView(
//         children: <Widget>[
//           Timeline(),
//           ActivityFeed(),
//           Upload(),
//           Search(),
//           Profile()
//         ],
//         controller: pageController,
//         onPageChanged: onPageChange,
//         physics: NeverScrollableScrollPhysics(),
//
//       ),
//       bottomNavigationBar: CupertinoTabBar(
//         currentIndex: pageIndex,
//         onTap: onTap,
//         activeColor: Theme.of(context).primaryColor,
//         items: [
//           BottomNavigationBarItem(icon: Icon(Icons.whatshot),),
//           BottomNavigationBarItem(icon: Icon(Icons.notifications_active),),
//           BottomNavigationBarItem(icon: Icon(Icons.photo_camera,size: 35.0,),),
//           BottomNavigationBarItem(icon: Icon(Icons.search),),
//           BottomNavigationBarItem(icon: Icon(Icons.account_circle),),
//         ],
//       ),
//     );
//   }
//
//   handleSignIn(GoogleSignInAccount account){
//     if(account!=null)
//       {
//         createUserInFireStore();
//       }
//
//   }
//   createUserInFireStore() async{
//     //1)check if user exists in users collection in database(according to their ID)
//     final  user = FirebaseAuth.instance.currentUser;
//     final DocumentSnapshot doc = await userRef.doc(user.uid).get();
//
//
//     //2)if the uer does not exists , then take them to the create account page
//     if(!doc.exists){
//       final username = Navigator.push(context, MaterialPageRoute(builder: (context)=>
//         CreateAccount()
//       ));
//       userRef.doc(user.uid).set({
//         "id": user.uid,
//         "username": username ,
//         "photoUrl" : user.photoURL,
//         "email" : user.email,
//         "displayName" : user.displayName,
//         "bio" : "",
//         "timestamp":timestamp
//       });
//
//
//     }
//
//
//     //3)get the username from create account, use it to mke the new user document in user collection
//
//
//
//
//   }
//
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     pageController = PageController( initialPage: 2);
//
//   }
//   @override
//   void dispose() {
//     pageController.dispose();
//     super.dispose();
//
//   }
//
//   @override
//   Widget build(BuildContext context) {
//
//     return Scaffold(
//
//        body: ChangeNotifierProvider(
//          create: (context)=>GoogleSignInProvider(),
//          child: StreamBuilder(
//            stream: FirebaseAuth.instance.authStateChanges(),
//            builder: (context,snapshot){
//              final provider = Provider.of<GoogleSignInProvider>(context);
//              if (provider.isSigningIn) {
//                return buildLoading();
//              } else if (snapshot.hasData) {
//                return buildAuthScreen();
//              } else {
//                return SignUpWidget();
//              }
//            },
//          ),
//
//        ),
//
//
//
//        // This trailing comma makes auto-formatting nicer for build methods.
//     );
//
//   }
//
//   Widget buildLoading() => Stack(
//     fit: StackFit.expand,
//     children: [
//
//       Center(child: CircularProgressIndicator()),
//     ],
//   );
// }
