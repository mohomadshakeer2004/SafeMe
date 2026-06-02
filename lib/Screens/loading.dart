import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:safe_me/Resources/colors.dart';
import 'package:safe_me/Screens/Login/languageSelect.dart';

import 'Login/LoginPage.dart';
 import 'home_base.dart';

class Loading extends StatefulWidget {
  const Loading({Key? key}) : super(key: key);

  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  void loaded() async {
    await Future.delayed(const Duration(seconds: 5), () async {
      await checkSession();
    });
  }

  checkSession() async {
    bool userSession = false; //await _userService.checkSession();
    print(userSession);
    if (userSession) {
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (_) => HomeBase()));

    } else {
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (_) => SelectLanguage()));
    }
  }

  @override
  void initState() {
    super.initState();
    // _userService = UserService(context);

    loaded();
  }

  @override
  Widget build(BuildContext context) {
    double sysHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: mainBGColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 7,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children:  [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 80, vertical: 20),
                  child: Image(
                    image: AssetImage("assets/images/logo.png"),
                  ),
                ),
                SpinKitThreeBounce(
                  size: 35,
                  color: secondary,
                )
              ],
            ),
          ),
          const Expanded(
            flex: 1,
            child: Text("Powered by Sri Lanka Police"),
          )
        ],
      ),
    );
  }
}