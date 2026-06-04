import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:motion_toast/resources/arrays.dart';
import '../../Controller/language_controller.dart';
import '../../Screens/Login/languageSelect.dart';
import 'package:provider/provider.dart';
import '../../Resources/colors.dart';
import '../../Resources/style.dart';
import '../../service/userService.dart';
import '../../util/user_data_util.dart';
import '../../widgets/forgotPasswordAlert.dart';
import '../home_base.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'signupPage1.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  final GlobalKey<FormBuilderState> _fbKeyValidation =
      GlobalKey<FormBuilderState>();

  final UserService _userService = UserService();

  final _txtEmailController = TextEditingController();
  final _txtPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    context.watch<LanguageController>();
    double sysHeight = MediaQuery.of(context).size.height;
    double sysWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mainBGColor,
        elevation: 0,
        iconTheme: IconThemeData(color: buttonColor),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SelectLanguage(),
                    ));
              },
              tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
            );
          },
        ),
      ),
      backgroundColor: mainBGColor,
      body: SafeArea(
        child: FormBuilder(
            key: _fbKey,
            child: Builder(
              builder: (context) {
                return SizedBox(
                  width: sysWidth,
                  height: sysHeight,
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Center(
                      child: ListView(
                        children: [
                          Image.asset(
                            "assets/images/logo.png",
                            height: sysWidth / 100 * 40,
                          ),
                          const SizedBox(height: 50),
                          Text(
                            'Hello'.tr(),
                            style: TextStyle(
                              fontSize: 30,
                              color: textBlackColor,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins-Light',
                            ),
                          ),
                          Text(
                            "Sign_In_txt".tr(),
                            style: TextStyle(
                              fontSize: 18,
                              color: textBlackColor,
                              fontFamily: 'Poppins-Light',
                            ),
                          ),
                          const SizedBox(height: 30),
                          FormBuilderTextField(
                            name: "nic",
                            style: normalWhiteTextStyle,
                            keyboardType: TextInputType.text,
                            textCapitalization: TextCapitalization.characters,
                            autofocus: false,
                            controller: _txtEmailController,
                            validator: (value) =>
                                value == null || value.trim().isEmpty
                                    ? 'NIC No is Required'
                                    : UserDataUtil.isValidNic(value)
                                        ? null
                                        : 'Enter a Valid NIC No',
                            decoration: InputDecoration(
                              labelText: "NIC".tr(),
                              labelStyle: hintTextStyle,
                              contentPadding:
                                  const EdgeInsets.fromLTRB(20, 10, 20, 10),
                              border: OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                  //  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: secondary)),
                            ),
                          ),
                          const SizedBox(height: 30),
                          FormBuilderTextField(
                            name: "password",
                            style: normalWhiteTextStyle,
                            keyboardType: TextInputType.text,
                            autofocus: false,
                            controller: _txtPasswordController,
                            obscureText: true,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return ('Password is Required');
                              }
                            },
                            decoration: InputDecoration(
                              labelText: "Password".tr(),
                              labelStyle: hintTextStyle,
                              contentPadding:
                                  EdgeInsets.fromLTRB(20, 10, 20, 10),
                              border: OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: secondary)),
                            ),
                          ),
                          const SizedBox(height: 30),
                          InkWell(
                            onTap: () async {
                              if (_fbKey.currentState!.saveAndValidate()) {
                                print(
                                    "*********${_fbKey.currentState?.value}***********");
                                EasyLoading.show(status: "Logging..");

                                bool result = false;
                                String? errorMessage;
                                try {
                                  result = await _userService.login(
                                    _fbKey.currentState!.value["nic"],
                                    _fbKey.currentState!.value["password"],
                                  );
                                } on FirebaseAuthException catch (e) {
                                  errorMessage =
                                      UserService.messageForAuthError(e) ??
                                          (e.message ?? e.code);
                                } catch (e) {
                                  errorMessage = e.toString();
                                }

                                EasyLoading.dismiss();
                                if (!mounted) return;
                                if (result == true) {
                                  print('******************');
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                        builder: (_) => HomeBase()),
                                    (route) => false,
                                  );
                                } else {
                                  print('-------------------');
                                  _txtPasswordController.clear();
                                  MotionToast.error(
                                    title: Text("Error"),
                                    description: Text(
                                      errorMessage ??
                                          "NIC No or Password Incorrect",
                                    ),
                                    animationType: AnimationType.slideInFromLeft,
                                    toastAlignment: Alignment.topCenter,
                                  ).show(context);
                                }
                              }
                            },
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(3),
                                color: buttonColor,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "Login".tr(),
                                    style: buttonTextStyle,
                                  )
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          TextButton(
                            onPressed: () {
                              print('Pressed forgot password');
                              ForgotPasswordAlert().getAlert(context).show();
                            },
                            child: Text(
                              'ForgotPassword'.tr(),
                              style: TextStyle(
                                  fontSize: 14,
                                  color: textBlackColor,
                                  fontFamily: 'Poppins-Light'),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Have_An_Account".tr(),
                                style: TextStyle(
                                    fontSize: 14,
                                    color: textBlackColor,
                                    fontFamily: 'Poppins-Light'),
                              ),
                              InkWell(
                                onTap: () {
                                  print('Pressed Signup');
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SignupScreen1(),
                                      ));
                                },
                                child: Text(
                                  "Sign_Up".tr(),
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: textBlackColor,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Poppins-Light'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            )),
      ),
    );
  }

}
