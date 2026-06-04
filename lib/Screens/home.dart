import 'dart:async';
import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:geolocator/geolocator.dart';
import 'package:safe_me/service/firebase_service.dart';
import 'package:safe_me/service/userService.dart';
import 'package:safe_me/util/user_data_util.dart';
import '../Screens/Complaint/complaint_base.dart';
import '../Screens/EmergencyContact/emergencyContact.dart';
import '../Screens/LostAndFound/lost_Found.dart';
import '../Screens/PoliceMap/policeMap.dart';
import '../Resources/colors.dart';
import '../Resources/style.dart';
import '../widgets/drawer.dart';
import 'Appoinment/appointment_base.dart';
import 'Emergency/emergency.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:safe_me/service/home_shake_service.dart';
import 'SafeMe/safeMeBase.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String mytext = "Martini?";
  Map<String, dynamic> userData = {};
  Position _position = Position(
      longitude: 0,
      latitude: 0,
      timestamp: DateTime.fromMillisecondsSinceEpoch(0),
      accuracy: 0,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0);

  TextEditingController _txtLocation = TextEditingController();

  getUserData() async {
    final nic = await UserService().requireLoggedInNic();
    if (nic == null) return;
    final snapshot = await FirebaseService.instance.getPublicUser(nic);

    if (!snapshot.exists || snapshot.value == null) {
      EasyLoading.dismiss();
      return;
    }

    Map<String, dynamic> data = UserDataUtil.withDefaults(
      jsonDecode(jsonEncode(snapshot.value)) as Map<String, dynamic>,
      nic,
    );
    if (!mounted) return;
    setState(() {
      userData = data;
    });

    print("************ User Data = ${data}**************");
    print("************  User Email = ${data['Email']}**************");
    EasyLoading.dismiss();
  }

  getCurrLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }

      final positionCur = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (!mounted) return;
      setState(() {
        _position = positionCur;
        _txtLocation.text =
            "${positionCur.latitude.toStringAsFixed(7)} , ${positionCur.longitude.toStringAsFixed(7)}";
      });
    } catch (e) {
      debugPrint('Location unavailable: $e');
    } finally {
      EasyLoading.dismiss();
    }
  }

  @override
  void initState() {
    super.initState();
    getUserData();
    getCurrLocation();
    _bindShakeHandler();
  }

  void _bindShakeHandler() {
    HomeShakeService.instance.onTripleShake = _onTripleShake;
  }

  void _onTripleShake() {
    if (!mounted) return;
    unawaited(_runShakeSafeMe());
  }

  Future<void> _runShakeSafeMe() async {
    print(
        '*************************ShakeDetector Start*****************************');

    final sessionOk = await UserService().checkSession();
    if (!sessionOk) {
      EasyLoading.showError('Please log in again');
      return;
    }

    if (userData.isEmpty) {
      await getUserData();
    }

    await submitSafeMe(
      UserDataUtil.field(userData, 'Address'),
      DateTime.now(),
      UserDataUtil.field(userData, 'Email'),
      _position.latitude,
      _position.longitude,
      UserDataUtil.mobileAsInt(userData),
      UserDataUtil.field(userData, 'NIC'),
      UserDataUtil.field(userData, 'Name'),
      UserDataUtil.field(userData, 'ProfileImage'),
    );
  }

  @override
  void reassemble() {
    super.reassemble();
    _bindShakeHandler();
  }

  @override
  void dispose() {
    HomeShakeService.instance.clearHandler();
    _txtLocation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double sysHeight = MediaQuery.of(context).size.height;
    double sysWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Color(0xffc0bfbf),
      // appBar: AppBar(
      //   elevation: 0,
      //   backgroundColor: Color(0xfff0f1f5),
      //   leading: Builder(
      //     builder: (BuildContext context) {
      //       return IconButton(
      //         icon: SvgPicture.asset(
      //           "assets/icons/menu.svg",
      //           height: sysWidth / 100 * 8,
      //           color: secondary,
      //         ),
      //         onPressed: () {
      //           Scaffold.of(context).openDrawer();
      //         },
      //         tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
      //       );
      //     },
      //   ),
      // ),
      drawer: Drawer(
        child: DrawerWidget(),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/bg1.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        // color: Color(0xfff0f1f5),
        height: sysHeight,
        width: sysWidth,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {
                      // launch('tel:0779873552');

                      const number = '1119'; //set the number here
                      FlutterPhoneDirectCaller.callNumber(number);
                    },
                    child: Container(
                      height: sysHeight / 6 * 1,
                      width: sysWidth - 40,
                      decoration: BoxDecoration(
                        color: Colors.white, // Color(0xfffdc2c2),
                        borderRadius: BorderRadius.circular(20),
                        //border: Border.all(width: 1,color: Colors.red),
                        // boxShadow: const [
                        //   BoxShadow(
                        //     blurRadius: 1,
                        //     color: Colors.black45,
                        //   )
                        // ]
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            //direction: Axis.vertical, //Vertical || Horizontal
                            children: <Widget>[
                              const Text(
                                "119",
                                style: TextStyle(
                                  fontSize: 38,
                                  color: Color(0xffff0000),
                                  letterSpacing: 8,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'ARLRDBD',
                                ),
                              ),
                              Text(
                                "Emergency".tr(),
                                style: const TextStyle(
                                    fontSize: 24,
                                    // height: 0.5,
                                    color: Color(0xffff0000),
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'ARLRDBD'),
                              ),
                            ],
                          ),
                          Image.asset(
                            "assets/images/ringing.gif",
                            height: 60,
                            // color: iconColor,
                          ),
                          // Icon(
                          //   Icons.call,
                          //   color: Color(0xffff0000),
                          //   size: 50,
                          // ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ComplaintHome()));
                    },
                    child: Container(
                      height: sysHeight / 6 * 1,
                      width: sysWidth / 3 * 1.3,
                      decoration: BoxDecoration(
                        // image: DecorationImage(
                        //   image: AssetImage("assets/images/aa.jpg"),
                        //   fit: BoxFit.cover,
                        //   colorFilter: new ColorFilter.mode(
                        //       Colors.black.withOpacity(1), BlendMode.dstATop),
                        // ),
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        // border: Border.all(color: Colors.black12)
                        // boxShadow: const [
                        //   BoxShadow(blurRadius: 0, color: Colors.black45)
                        // ]
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          // crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Complaint".tr(),
                                  style: mainTilsTextStyle,
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  "assets/icons/complaint.png",
                                  height: sysWidth / 100 * 10,
                                  color: secondary,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SafeMeBase()));
                    },
                    child: Container(
                      height: sysHeight / 6 * 1,
                      width: sysWidth / 3 * 1.3,
                      decoration: BoxDecoration(
                        // image: DecorationImage(
                        //   image: AssetImage("assets/images/2.jpg"),
                        //   fit: BoxFit.cover,
                        //   colorFilter: new ColorFilter.mode(
                        //       Colors.black.withOpacity(0.5),
                        //       BlendMode.dstATop),
                        // ),
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        // border: Border.all(color: Colors.black12)
                        // boxShadow: const [
                        //   BoxShadow(blurRadius: 0, color: Colors.black45)
                        // ]
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          //crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Safe_Me".tr(),
                                  style: mainTilsTextStyle,
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  "assets/icons/safe.png",
                                  height: sysWidth / 100 * 10,
                                  color: secondary,
                                ),
                              ],
                            ),

                            // Icon(FontAwesomeIcons.microphoneLines,
                            //     size: 45, color: buttonColor),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AppointmentBase()));
                    },
                    child: Container(
                      height: sysHeight / 6 * 1,
                      width: sysWidth / 3 * 1.3,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            // BoxShadow(blurRadius: 1, color: Colors.black45)
                          ]),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          // crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Appointment".tr(),
                                  style: mainTilsTextStyle,
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  "assets/icons/appointment.png",
                                  height: sysWidth / 100 * 10,
                                  color: secondary,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const PoliceMap()));
                    },
                    child: Container(
                      height: sysHeight / 6 * 1,
                      width: sysWidth / 3 * 1.3,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            // BoxShadow(blurRadius: 1, color: Colors.black45)
                          ]),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          //crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Police_Map".tr(),
                                  style: mainTilsTextStyle,
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  "assets/icons/nearest.png",
                                  height: sysWidth / 100 * 10,
                                  color: secondary,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LostFoundItem()));
                    },
                    child: Container(
                      height: sysHeight / 6 * 1,
                      width: sysWidth / 3 * 1.3,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            // BoxShadow(blurRadius: 1, color: Colors.black45)
                          ]),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          // crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Lost_Found".tr(),
                                  style: mainTilsTextStyle,
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  "assets/icons/lost_found.png",
                                  height: sysWidth / 100 * 10,
                                  color: secondary,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const EmergencyContact()));
                    },
                    child: Container(
                      height: sysHeight / 6 * 1,
                      width: sysWidth / 3 * 1.3,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            // BoxShadow(blurRadius: 1, color: Colors.black45)
                          ]),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          //crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Contact".tr(),
                                  style: mainTilsTextStyle,
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  "assets/icons/contact.png",
                                  height: sysWidth / 100 * 10,
                                  color: secondary,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> submitSafeMe(
    String Address,
    DateTime Date,
    String Email,
    double Latitude,
    double Longitude,
    int Mobile,
    String NIC,
    String Name,
    String ProfileImage,
  ) async {
    EasyLoading.show(status: "Submitting...");
    try {
      final firebase = FirebaseService.instance;
      final sid = await firebase.allocateNextSafeMeId();
      print('shake submitSafeMe: SID=$sid');

      final data = {
        'SID': sid,
        'Address': Address,
        'AudioMP3': '',
        'City': UserDataUtil.field(userData, 'City'),
        'Date': Date.toString(),
        'District': UserDataUtil.field(userData, 'District'),
        'Email': Email,
        'Image1': '',
        'Image2': '',
        'Image3': '',
        'Image4': '',
        'Image5': '',
        'Latitude': Latitude,
        'Longitude': Longitude,
        'Mobile': Mobile,
        'NIC': UserDataUtil.normalizeNic(NIC),
        'Name': Name,
        'ProfileImage': ProfileImage,
        'Severity': 'Medium',
        'Status': 'Alert Sent',
      };

      await firebase.saveSafeMeAlert(sid: sid, data: data);
      await firebase.syncSafeMeCounters(sid);

      EasyLoading.showSuccess('SafeMe alert sent!');
      return true;
    } catch (e) {
      print('shake submitSafeMe failed: $e');
      EasyLoading.showError('SafeMe alert failed');
      return false;
    } finally {
      EasyLoading.dismiss();
    }
  }
}
