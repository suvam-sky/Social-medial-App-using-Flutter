import 'package:flutter/material.dart';

import 'google_signin_button.dart';

class SignUpWidget extends StatelessWidget {
  const SignUpWidget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [

      buildSignUp(),
    ],
  );

  Widget buildSignUp() => Column(
    children: [
      Spacer(),
      Align(
        alignment: Alignment.centerLeft,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 20),
          width: 175,
          child: Text(
            'Welcome Back To MyApp',
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      Spacer(),
      GoogleSignupButtonWidget(),
      SizedBox(height: 12),
      Text(
        'Login to continue',
        style: TextStyle(fontSize: 16),
      ),
      Spacer(),
    ],
  );
}
