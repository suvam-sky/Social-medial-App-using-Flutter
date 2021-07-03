import 'package:flutter/material.dart';
import 'package:flutter_firebase/widgets/header.dart';

class CreateAccount extends StatefulWidget {
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  @override
  Widget build(BuildContext parentContext) {
    String username;
    final _formKey =  GlobalKey<FormState>();


    submit(){
      _formKey.currentState.save();
      Navigator.pop(context, username);
    }

    return Scaffold(
      appBar: header(context,isAppTitle: false,titleText: "Set Up your profile" ),
      body: ListView(
        children: [
          Container(
            child: Column(
              children: [
                Padding(padding: EdgeInsets.only(top: 25),
                child: Center(
                  child: Text("Create a username",style: TextStyle(fontSize: 25),),
                ),

                ),
                Padding(padding: EdgeInsets.all(16),
                child: Container(
                  child: Form(
                    key: _formKey,
                    child: TextFormField(
                      onSaved: (val)=> username = val  ,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Username",
                        labelStyle: TextStyle(fontSize: 15),
                        hintText: "Must be at least 3 character"
                      ),
                    ),
                  ),
                ),
                ),
                GestureDetector(
                  onTap: submit,
                  child: Center(
                    child: Container(
                      height: 50,
                      width: 350,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(7)
                      ),
                      child: Center(
                        child: Text("Submit",
                          style: TextStyle(color: Colors.white,fontSize: 15,fontWeight: FontWeight.bold),),
                      ),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ) ,
    );
  }
}