import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_svg/svg.dart';
import 'package:safe_me/Screens/Login/signupPage3.dart';
import 'package:provider/provider.dart';
import '../../Controller/language_controller.dart';
import '../../Resources/colors.dart';
import '../../Resources/style.dart';

class SignupScreen2 extends StatefulWidget {
  SignupScreen2(this.fName, this.lName, this.NIC, this.mobileNo, this.email, this.image);

  final String fName;
  final String lName;
  final String NIC;
  final String mobileNo;
  final String email;
  final String image;

  @override
  _SignupScreen2State createState() => _SignupScreen2State();
}

class _SignupScreen2State extends State<SignupScreen2> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  final GlobalKey<FormBuilderState> _fbKeyValidation =
      GlobalKey<FormBuilderState>();

  final _txtPasswordController = TextEditingController();
  final _txtCPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    context.watch<LanguageController>();
    double sysWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: mainBGColor,
      appBar: AppBar(
        backgroundColor: mainBGColor,
        elevation: 0,
        iconTheme: IconThemeData(
          color: buttonColor, //change your color here
        ),
      ),
      body: SafeArea(
        child: FormBuilder(
            // autovalidateMode: AutovalidateMode.onUserInteraction,
            key: _fbKey,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: ListView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  Image.asset(
                    "assets/images/logo.png",
                    height: sysWidth * 0.25,
                  ),
                          const SizedBox(height: 50),
                          Text(
                            "Password".tr(),
                            style: TextStyle(
                              fontSize: 30,
                              color: textBlackColor,
                              fontFamily: 'Poppins-Regular',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Password_txt".tr(),
                            style: TextStyle(
                              fontSize: 18,
                              color: textBlackColor,
                              fontFamily: 'Poppins-Light',
                            ),
                          ),
                          const SizedBox(height: 30),
                          FormBuilderTextField(
                            name: "password",
                            style: normalWhiteTextStyle,
                            keyboardType: TextInputType.visiblePassword,
                            cursorColor: iconColor,
                            autofocus: false,
                            obscureText: true,
                            controller: _txtPasswordController,
                            validator: (value) =>
                                value == null || value.isEmpty
                                    ? 'Password is Required'
                                    : null,
                            decoration: InputDecoration(
                              labelText: "Password".tr(),
                              labelStyle: hintTextStyle,
                              contentPadding:
                                  const EdgeInsets.fromLTRB(20, 10, 20, 10),
                              border: OutlineInputBorder(
                                  // borderRadius: BorderRadius.circular(10)
                                  ),
                              focusedBorder: OutlineInputBorder(
                                  // borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: secondary)),
                            ),
                          ),
                          const SizedBox(height: 30),
                          FormBuilderTextField(
                            name: "cPassword",
                            style: normalWhiteTextStyle,
                            keyboardType: TextInputType.visiblePassword,
                            cursorColor: iconColor,
                            autofocus: false,
                            obscureText: true,
                            controller: _txtCPasswordController,
                            validator: (value) => value!.isEmpty
                                ? 'Conform password is Required'
                                : _txtPasswordController.text ==
                                        _txtCPasswordController.text
                                    ? null
                                    : "Confirm Password not Matching",
                            decoration: InputDecoration(
                              labelText: "CPassword".tr(),
                              labelStyle: hintTextStyle,
                              contentPadding:
                                  const EdgeInsets.fromLTRB(20, 10, 20, 10),
                              border: OutlineInputBorder(
                                  // borderRadius: BorderRadius.circular(10)
                                  ),
                              focusedBorder: OutlineInputBorder(
                                  //borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: secondary)),
                            ),
                          ),
                          const SizedBox(height: 30),
                          InkWell(
                            onTap: () async {
                              if (_fbKey.currentState!.validate()) {
                                print("******Validate******");

                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SignupScreen3(
                                          widget.fName,
                                          widget.lName,
                                          widget.NIC,
                                          widget.mobileNo,
                                          widget.email,
                                          widget.image,
                                          _txtCPasswordController.text),
                                    ));
                              } else {
                                print("******Not Validate******");
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
                                    "Next".tr(),
                                    style: buttonTextStyle,
                                  )
                                ],
                              ),
                            ),
                          ),
                  const SizedBox(height: 20),
                ],
              ),
            )),
      ),
    );
  }
}
