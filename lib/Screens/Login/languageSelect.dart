import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:safe_me/Controller/language_controller.dart';
import 'package:safe_me/Screens/Login/LoginPage.dart';
import 'package:provider/provider.dart';
import '../../Resources/colors.dart';
import '../../Resources/style.dart';

class SelectLanguage extends StatefulWidget {
  const SelectLanguage({Key? key}) : super(key: key);

  @override
  _SelectLanguageState createState() => _SelectLanguageState();
}

class _SelectLanguageState extends State<SelectLanguage> {
  int select = 0; //0 - en select // 1 - si select

  @override
  Widget build(BuildContext context) {
    LanguageController controller = context.read<LanguageController>();

    double sysHeight = MediaQuery.of(context).size.height;
    double sysWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          width: sysWidth,
          height: sysHeight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                "assets/images/language.png",
                height: sysWidth / 100 * 30,
                color: primaryColor,
              ),
              // const SizedBox(height: 50),

              Container(
                width: sysWidth,
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'change_language'.tr(),
                        style: TextStyle(
                          fontSize: 20,
                          color: textBlackColor,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins-Light',
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          InkWell(
                            onTap: () {
                              setState(() {
                                select = 0;
                              });
                              context.locale = Locale('en', 'US');
                              controller.onLanguageChanged();
                            },
                            child: Container(
                              height: 50,
                              width: sysWidth / 3,
                              decoration: BoxDecoration(
                                  color:
                                      select == 0 ? primaryColor : mainBGColor,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: const [
                                    BoxShadow(
                                        blurRadius: 1, color: Colors.black45)
                                  ]),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'English',
                                    style: TextStyle(
                                        // fontSize: 20,
                                        color: select == 0
                                            ? mainBGColor
                                            : buttonColor,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Poppins-Light'),
                                  )
                                ],
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                select = 1;
                              });
                              context.locale = Locale('si', 'SL');
                              controller.onLanguageChanged();
                            },
                            child: Container(
                              height: 50,
                              width: sysWidth / 3,
                              decoration: BoxDecoration(
                                  color:
                                      select == 1 ? primaryColor : mainBGColor,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: const [
                                    BoxShadow(
                                        blurRadius: 1, color: Colors.black45)
                                  ]),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'සිංහල',
                                    style: TextStyle(
                                        // fontSize: 20,
                                        color: select == 1
                                            ? mainBGColor
                                            : buttonColor,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Poppins-Light'),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ]),
                  ],
                ),
              ),

              //const SizedBox(height: 30),
              InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginPage(),
                      ));
                },
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: buttonColor,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Next'.tr(),
                        style: buttonTextStyle,
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
