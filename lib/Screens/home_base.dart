import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:safe_me/service/emergency_audio_service.dart';
import 'package:safe_me/service/home_shake_service.dart';
import '../Resources/colors.dart';
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
    EasyLoading.dismiss();
    if (!mounted) return;
    setState(() {});
  }

  void _syncShakeListener() {
    if (selectedpage == 0) {
      HomeShakeService.instance.start();
    } else {
      HomeShakeService.instance.stop();
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      selectedpage = index;
    });
    _syncShakeListener();
  }

  @override
  void initState() {
    super.initState();
    getUser();
    _syncShakeListener();
  }

  @override
  void reassemble() {
    super.reassemble();
    HomeShakeService.instance.stop();
    _syncShakeListener();
  }

  @override
  void dispose() {
    HomeShakeService.instance.stop();
    EmergencyAudioService.instance.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [],
    );
    return SafeArea(
      child: Scaffold(
        body: IndexedStack(
          index: selectedpage,
          children: [
            const HomeScreen(),
            ProfileScreen(),
          ],
        ),
        backgroundColor: mainBGColor,
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.bars),
              label: '',
            ),
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
    );
  }
}
