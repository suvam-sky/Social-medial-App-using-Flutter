import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase/models/user.dart';
import 'package:flutter_firebase/pages/home.dart';
import 'package:flutter_firebase/widgets/progress.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_firebase/main.dart';

import 'activity_feed.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  TextEditingController searchController = TextEditingController();
  Future<QuerySnapshot> searchResultFuture;

  handleSearch(String query){
    Future<QuerySnapshot> users = userRef.where("displayName",isGreaterThanOrEqualTo:query ).get();

    setState(() {
      searchResultFuture=users;
    });

  }

  clearSearch(){
    searchController.clear();
  }

  AppBar buildSearchField(){
      return AppBar(
        backgroundColor: Colors.white,
        title:TextFormField(
          controller: searchController,
          decoration: InputDecoration(
            hintText: "Search for an user.....",
            filled: true,
            prefixIcon: Icon(Icons.account_box,size: 28,),
            suffixIcon: IconButton(
              icon: Icon(Icons.clear),
              onPressed: clearSearch,
            )
          ) ,
          onFieldSubmitted: handleSearch ,
        ),
      );
  }

  Container buildNoContent(){
    return Container(
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: [
            SvgPicture.asset("assets/images/search.svg",height: 300,),
            Text("Find User",textAlign: TextAlign.center,style: TextStyle(
              color: Colors.blue,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w600,
              fontSize: 60
            ),)
          ],
        ),
      ),
    );
  }

   buildSearchResults(){
    // return StreamBuilder(
    //     stream:FirebaseFirestore.instance.collection('users').where('displayName',isGreaterThanOrEqualTo: "suvam").snapshots(),
    //   builder: (_,snapshot){
    //       if(snapshot.hasData){
    //         return Column(
    //           children: snapshot.data.docs.map( (val)=>
    //               val.data()['username'],
    //
    //           ),
    //         );
    //       }
    //       else{
    //         print('---------noooooo---------');
    //         return Container();
    //       }
    //   },
    //
    // );
    
    return FutureBuilder(
      future: searchResultFuture,
      builder: (context,snapshot){
        if(!snapshot.hasData){
          return circularProgress();
        }
        List<UserResult>searchResults=[];

      final data  = snapshot.requireData;

        // snapshot.data.docs.forEach((doc){
        //   User user = User.fromDocument(doc);
        //   print(snapshot.data);
        //
        //   UserResult searchResult = UserResult(user);
        //
        //   searchResults.add(searchResult);
        // });
        //print("---------------the ans is-------------"+ data.size.toString() );
        //print("---------------the ans is-------------"+ data.docs[1].data() );


        return ListView.builder(
          itemCount: data.size,
          itemBuilder: (context,index){
            return UserResult(data.docs[index].data(),data.docs[index].reference);
          },
        );
     },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.8),
      appBar: buildSearchField(),
      body: searchResultFuture == null ?  buildNoContent() : buildSearchResults(),
    );
  }
}

class UserResult extends StatelessWidget {
  //final User user;
  final DocumentReference ref;
  Map<String,dynamic>m;
  UserResult(this.m,this.ref);



  @override
  Widget build(BuildContext context) {
    return
      Container(
      color: Theme.of(context).primaryColor.withOpacity(0.7),
      child: Column(
        children: [
          GestureDetector(
            onTap: ()=>showProfile(context,profileId: m['id'] ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.grey,
                backgroundImage: CachedNetworkImageProvider(m['photoUrl']),
              ),
              title: Text(m['displayName'],style: TextStyle(
                color: Colors.black,fontWeight: FontWeight.bold
              ),),
            ),
          ),
          Divider(
            height: 2.0,
            color: Colors.white54,
          )
        ],
      ),
    );
  }
}