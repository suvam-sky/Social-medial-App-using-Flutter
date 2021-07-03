import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase/models/user.dart';
import 'package:flutter_firebase/pages/home.dart';
import 'package:flutter_firebase/widgets/progress.dart';

class EditProfile extends StatefulWidget {
  //const EditProfile({Key key}) : super(key: key);
  final String currentUserId;
  EditProfile({this.currentUserId});

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  TextEditingController displayNameController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  bool isLoading = false;
  User user;
  bool _displayNameValid=true;
  bool _bioValid=true;
  final _scaffoldKey = GlobalKey<ScaffoldState>();


  Column buildBioNameField(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: EdgeInsets.only(top: 12),
          child: Text("Bio",style: TextStyle(
              color: Colors.grey),
          ),
        ),
        TextField(
          controller: bioController,
          decoration: InputDecoration(
              hintText: "Update Bio",
              errorText: _bioValid ? null :"Bio too long"
          ),
        )
      ],
    );
  }

  Column buildDisplayNameField(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: EdgeInsets.only(top: 12),
        child: Text("Display Name",style: TextStyle(
          color: Colors.grey),
        ),
        ),
        TextField(
          controller: displayNameController,
          decoration: InputDecoration(
            hintText: "Update Display Name",
            errorText: _displayNameValid ? null :"Display Name too short"

          ),
        )
      ],
    );
  }


  updateProfileData(){
    setState(() {
      displayNameController.text.trim().length< 3 || displayNameController.text.isEmpty ? _displayNameValid=false:
          _displayNameValid=true;
      bioController.text.trim().length>100 ? _bioValid=false : _bioValid=true;

    });

    if(_displayNameValid && _bioValid){
      userRef.doc(widget.currentUserId).update({
        "displayName":displayNameController.text,
        "bio":bioController.text
      });


      SnackBar snackBar = SnackBar(content: Text("Profile Updated..."));

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  logout()async{
    await googleSignIn.signOut();
    Navigator.push(context,MaterialPageRoute(builder: (context)=>
        Home()
    ) );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Edit Profile", style: TextStyle(color: Colors.black),
        ),
        actions: [
          IconButton(icon: Icon(Icons.done,size: 30,color: Colors.green,),
              onPressed: ()=>Navigator.pop(context) )
        ],
      ),
      body: isLoading ? circularProgress() : ListView(
        children: [
          Container(
            child: Column(
              children: [
                Padding(padding: EdgeInsets.only(top: 16,bottom: 8),
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: CachedNetworkImageProvider(user.photoUrl),
                ),
                ),
                Padding(padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    buildDisplayNameField(),
                    buildBioNameField(),
                  ],
                ) ,
                ),
                ElevatedButton(
                    onPressed: updateProfileData,
                    child: Text("Update Profile",style: TextStyle(
                      color: Colors.white,fontSize: 20,fontWeight: FontWeight.bold
                    ),),
                ),
                Padding(padding: EdgeInsets.all(16),
                child: TextButton.icon(
                  onPressed:logout,
                  icon: Icon(Icons.logout,color: Colors.red,

                  ),
                  label: Text("Logout",style: TextStyle(
                    color: Colors.red,fontSize: 20
                  ),),

                ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    getUser();
  }

  getUser()async{
    setState(() {
      isLoading=true;
    });

    DocumentSnapshot doc =await userRef.doc(widget.currentUserId).get();
    user = User.fromDocument(doc);
    displayNameController.text = user.displayName;
    bioController.text = user.bio;
    setState(() {
      isLoading=false;
    });

  }


}

