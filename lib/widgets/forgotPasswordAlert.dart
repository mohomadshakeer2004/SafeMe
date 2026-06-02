import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import '../Controller/language_controller.dart';
import '../Resources/colors.dart';
import '../Resources/style.dart';
import 'forgotPasswordAlertContent.dart';
import 'visible_dialogbutton.dart';

class ForgotPasswordAlert {
  bool isCodeSentBool = false;
  static final ForgotPasswordAlert _forgotPasswordAlert =
      ForgotPasswordAlert._internal();

  factory ForgotPasswordAlert() {
    return _forgotPasswordAlert;
  }

  ForgotPasswordAlert._internal();

  Alert getAlert(BuildContext context) {
    // ignore: close_sinks
    final StreamController<bool> isCodeSent =
        StreamController<bool>.broadcast();

    // ignore: close_sinks
    final StreamController<bool> isLoading = StreamController<bool>();
    final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
    // context.watch<LanguageController>();
    double sysHeight = MediaQuery.of(context).size.height;
    // double sysWidth = MediaQuery.of(context).size.width;
    // var height001 = sysHeight * 0.01;
    return Alert(
        style: AlertStyle(
          backgroundColor: mainBGColor,
          titleStyle: TextStyle(
            fontSize: 20,
            fontFamily: 'Poppins-Light',
            color: textBlackColor,
             fontWeight: FontWeight.bold,
          ),
        ),
        context: context,
        title: 'ForgotPassword1'.tr(),
        content: ForgotPasswordAlertContent(_fbKey, isLoading, isCodeSent),
        buttons: [
          DialogButton(
            height: sysHeight * 0.06,
            color: buttonColor,
            onPressed: () async {
              // if (_fbKey.currentState!.saveAndValidate()) {
              //   print(_fbKey.currentState?.value);
              //   isLoading.sink.add(true);
              //   var result = await _forgotPasswordService
              //       .requestForgotPassword(_fbKey.currentState?.value["email"]);
              //   if (result["status"]) {
              //     EasyLoading.showSuccess("Success! Please check your email.");
              //     EasyLoading.dismiss();
              isCodeSent.sink.add(true);
              //   } else {
              //     EasyLoading.showError(result["message"]);
              //     EasyLoading.dismiss();
              //     if (result["error_code"] == 105) {
              //       isCodeSent.sink.add(true);
              //     }
              //   }
              //   isLoading.sink.add(false);
              // }
            },
            child: FittedBox(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              child: Text('Request'.tr(), style: buttonTextStyle),
            ),
          ),
          VisibleDialogButton(
            stream: isCodeSent.stream,
            height: sysHeight * 0.06,
            color: buttonColor,
            onPressed: () async {
              // if (_fbKey.currentState!.saveAndValidate()) {
              //   print(_fbKey.currentState?.value);
              // isLoading.sink.add(true);
              //   var result = await _forgotPasswordService.resetForgotPassword(
              //       _fbKey.currentState?.value["email"],
              //       _fbKey.currentState?.value["code"],
              //       _fbKey.currentState?.value["password"]);
              //   if (result["status"]) {
              //     EasyLoading.showSuccess("Your Password Reset. Please login.");
              //     EasyLoading.dismiss();
              //     Navigator.pushReplacement(context,
              //         MaterialPageRoute(builder: (context) => LoginScreen()));
              //   } else {
              //     EasyLoading.showError(result["message"]);
              //     EasyLoading.dismiss();
              //   }
              //   isLoading.sink.add(false);
              // }
            },
            child: FittedBox(
              child: Text(
                'Reset'.tr(),
                style: buttonTextStyle,
              ),
            ),
          ),
        ]);
  }
}
