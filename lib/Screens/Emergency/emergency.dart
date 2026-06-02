import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:safe_me/Screens/home_base.dart';
import 'package:provider/provider.dart';

import '../../Controller/language_controller.dart';
import '../../Resources/colors.dart';
import '../../widgets/drawer.dart';

class Emergency extends StatefulWidget {
  const Emergency({Key? key}) : super(key: key);

  @override
  _EmergencyState createState() => _EmergencyState();
}

class _EmergencyState extends State<Emergency> {
  @override
  Widget build(BuildContext context) {
    context.watch<LanguageController>();
    double sysHeight = MediaQuery.of(context).size.height;
    double sysWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: mainBGColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: mainBGColor,
       // iconTheme: IconThemeData(color: iconColor),
        title: Text(
          "119_Emergency".tr(),
          style: TextStyle(fontSize: 22, color: iconColor),
        ),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: SvgPicture.asset(
                "assets/icons/menu.svg",
                height: sysWidth / 100 * 8,
                color: buttonColor,
              ),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: iconColor,
              size: 30,
            ),
            onPressed: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                      const HomeBase()));
            },
          ),
        ],
      ),

      drawer: Drawer(
        child: DrawerWidget(),
      ),
      body: Container(
        height: sysHeight,
        width: sysWidth,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            children: [
              InkWell(
                onTap: () {
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //         builder: (context) =>
                  //         const Emergency()));
                },
                child: Container(
                  height: sysHeight / 6 * 1,
                  width: sysWidth - 40,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      //border: Border.all(width: 1,color: Colors.red),
                      boxShadow: const [
                        BoxShadow(
                          blurRadius: 1,
                          color: Colors.black45,
                        )
                      ]),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Call_119".tr(),
                        style: TextStyle(
                            fontSize: 30,
                            color: buttonColor,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins-Regular'),
                      ),
                      Icon(
                        FontAwesomeIcons.phoneVolume,
                        color: iconColor,
                        size: 35,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              InkWell(
                onTap: () {
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //         builder: (context) =>
                  //         const Emergency()));
                },
                child: Container(
                  height: sysHeight / 6 * 1,
                  width: sysWidth - 40,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      //border: Border.all(width: 1,color: Colors.red),
                      boxShadow: const [
                        BoxShadow(
                          blurRadius: 1,
                          color: Colors.black45,
                        )
                      ]),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Form_119".tr(),
                        style: TextStyle(
                            fontSize: 30,
                            color: buttonColor,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins-Regular'),
                      ),
                      Icon(
                        FontAwesomeIcons.filePen,
                        color: iconColor,
                        size: 35,
                      ),
                    ],
                  ),
                ),
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
}
