import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:safe_me/Screens/notification.dart';
import '../Resources/colors.dart';
import '../widgets/drawer.dart';
import 'home.dart';
import 'profile.dart';

class HomeBase extends StatefulWidget {
  const HomeBase({Key? key}) : super(key: key);

  @override
  _HomeBaseState createState() => _HomeBaseState();
}

class _HomeBaseState extends State<HomeBase> {
  int selectedpage = 0;

  getUser() async {
   // EasyLoading.show(status: "Loading Data...");
    //  UserModel userModel = await Resources.getUser(_userService);
     EasyLoading.dismiss();
    setState(() {
      //    Resources.user = userModel;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      selectedpage = index;
    });
  }

  final _pageOptions = [
    HomeScreen(),
    // SubmissionsList(),
  //  NotificationScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    getUser();
  }

  @override
  Widget build(BuildContext context) {
    late double sysWidth = MediaQuery.of(context).size.width / 100;
    late double sysHeight = MediaQuery.of(context).size.height;
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [],
    );
    return FlutterEasyLoading(
      key: Key("HomeBase"),
      child: SafeArea(
        child: Scaffold(
          body: _pageOptions[selectedpage],
          backgroundColor: mainBGColor,
          bottomNavigationBar: BottomNavigationBar(
             // type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(FontAwesomeIcons.bars),
                label: '',
              ),
              // BottomNavigationBarItem(
              //   icon: Icon(FontAwesomeIcons.history),
              //   label: '',
              // ),
              // BottomNavigationBarItem(
              //   icon: Icon(FontAwesomeIcons.bell),
              //   label: '',
              // ),
               BottomNavigationBarItem(
                icon: Icon(
                  FontAwesomeIcons.user,
                ),
                label: '',
              ),
            ],
            currentIndex: selectedpage,
            selectedItemColor: secondary,
            unselectedItemColor: IconColor2,
            iconSize: 20,
            onTap: _onItemTapped,
          ),
        ),
      ),
    );
  }
}
