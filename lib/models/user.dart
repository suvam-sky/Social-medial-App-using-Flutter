
import 'package:cloud_firestore/cloud_firestore.dart';

class User{

  final String id;
  final String username;
  final String email;
  final String photoUrl;
  final String displayName;
  final String bio;

  User({
   this.id,
   this.displayName,
   this.email,
   this.username,
   this.bio,
   this.photoUrl
});

  factory User.fromDocument(DocumentSnapshot doc){
    return User(
      id: doc['id'],
      email: doc['email'],
      username: doc['username'],
      photoUrl: doc['photoUrl'],
      bio: doc['bio'],
      displayName: doc['displayName']

    );
  }


}