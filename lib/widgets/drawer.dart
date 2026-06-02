import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:safe_me/Screens/home_base.dart';
import '../Resources/colors.dart';

import '../Resources/style.dart';
import '../Screens/Login/languageSelect.dart';

class DrawerWidget extends StatefulWidget {
  @override
  _DrawerWidgetState createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  Map<String, dynamic> userData = {};

  getUserData() async {
    String nic = "951240999V";
    EasyLoading.show(status: "Getting User Data");
    final databaseRef = FirebaseDatabase.instance.ref();

    var get_UserData = databaseRef.child('/PublicUsers/All/').child(nic);
    DatabaseEvent event = await get_UserData.once();
    String aa = (event.snapshot.value).toString();
    Map<String, dynamic> data =
    jsonDecode(jsonEncode(event.snapshot.value)) as Map<String, dynamic>;
    setState(() {
      userData = data;
    });

    print("************ User Data = ${data}**************");
    print("************  User Email = ${data['Email']}**************");
    EasyLoading.dismiss();
  }


  @override
  void initState() {
    super.initState();
    getUserData();
  }

  @override
  Widget build(BuildContext context) {
    double sysHeight = MediaQuery.of(context).size.height / 100;
    double sysWidth = MediaQuery.of(context).size.width;
    double FontSize = MediaQuery.of(context).size.height / 100;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/background.jpg"),
                fit: BoxFit.cover,
              ),
            ),
            // color: primaryColor,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                      onPressed: () => Navigator.of(context).pop(null),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 45,
                      backgroundColor: boxLineColor,
                      child: CachedNetworkImage(
                        imageUrl:userData['ProfileImage'],
                                 imageBuilder: (context, imageProvider) => CircleAvatar(
                          radius: 43,
                          backgroundColor: Colors.black12,
                          backgroundImage: imageProvider,
                        ),
                        placeholder: (context, url) =>
                            CircularProgressIndicator(),
                        errorWidget: (context, url, error) =>
                            const CircleAvatar(
                          radius: 43,
                          backgroundColor: Colors.black12,
                          backgroundImage:
                              AssetImage("assets/images/no-profile.png"),
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    Text(
                      userData['Name'],
                      style: TextStyle(
                          color: textColor_2,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins-Light',
                          fontSize: FontSize * 2.4),
                    ),
                    SizedBox(height: 5),
                    Text(
                      userData['Email'],
                      style: TextStyle(
                          color: Colors.white60,
                          fontFamily: 'Poppins-Light',
                          fontSize: FontSize * 1.7),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Expanded(
            flex: 6,
            // width: sysWidth * 0.4,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  child: Column(children: [
                    SizedBox(
                      height: 10,
                    ),
                    ListTile(
                        leading:
                            Icon(FontAwesomeIcons.homeLg, color: secondary),
                        title: Text(
                          "Home",
                          style: normalWhiteTextStyle,
                        ),
                        onTap: () {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HomeBase(),
                              ));
                        }),
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Divider(),
                    ),
                    ListTile(
                      leading: Icon(FontAwesomeIcons.fileAlt, color: secondary),
                      title: Text(
                        "Terms and Condition",
                        style: normalWhiteTextStyle,
                      ),
                      onTap: () {},
                    ),
                    ListTile(
                      leading:
                          Icon(FontAwesomeIcons.shieldHalved, color: secondary),
                      title: Text(
                        "Privacy Policy",
                        style: normalWhiteTextStyle,
                      ),
                      onTap: () {},
                    ),
                  ]),
                ),
                Container(
                  child: Column(children: [
                    const Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Divider(),
                    ),
                    ListTile(
                      leading:
                          Icon(FontAwesomeIcons.signOutAlt, color: secondary),
                      title: Text(
                        "Logout",
                        style: normalWhiteTextStyle,
                      ),
                      onTap: () async {
                        // await _userService.onUserFetchError();

                        Navigator.pop(context);
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SelectLanguage()));
                      },
                    ),
                  ]),
                )
              ],
            )),
      ],
    );
  }
}
