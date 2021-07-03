import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

AppBar header(context ,{ bool isAppTitle = false , String titleText} ) {
  return AppBar(
    title: Text(isAppTitle?
      "Flutter Share": titleText ,
      style: TextStyle(color: Colors.white ,
          fontFamily: "Signatra",
          fontSize: isAppTitle ?50:26),
      overflow: TextOverflow.ellipsis,
    ),


    centerTitle: true,
    backgroundColor: Theme.of(context).accentColor,
  );
}

class GradientAppBar extends StatelessWidget  implements PreferredSizeWidget{
  //const GradientAppBar({Key key}) : super(key: key);


  bool isAppTitle;
  String titleText;
  GradientAppBar({this.titleText,this.isAppTitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      alignment: Alignment.center,
      padding: EdgeInsets.only(top: 20.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
              Color(0xff7f00ff),
              Color(0xffe100ff)
          ]
        )
      ),
      child: Text(isAppTitle?
      "Flutter Share": titleText ,
        style: TextStyle(color: Colors.white ,
            fontWeight: FontWeight.w400,
            fontFamily: 'Dancing Script',
            fontSize: isAppTitle ?50:26),
        overflow: TextOverflow.ellipsis,
      ) ,
    );
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => Size.fromHeight(80.0);
}

