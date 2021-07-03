import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../google_sign_in.dart';

class DrawerWidget extends StatelessWidget {
  //const DrawerWidget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;


    return  Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
                accountName: Text(user.displayName),
                accountEmail: Text(user.email),
              currentAccountPicture: CircleAvatar(
                backgroundImage: NetworkImage(user.photoURL),
              ),

            ),
            ListTile(
              leading: Icon(Icons.logout),title: Text('Logout'),
              onTap: (){
                final provider =
                Provider.of<GoogleSignInProvider>(context, listen: false);
                provider.logout();
              },
            )
          ],
        ),
      );

  }
}
