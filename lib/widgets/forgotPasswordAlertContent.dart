import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../Controller/language_controller.dart';
import '../Resources/colors.dart';
import '../Resources/style.dart';

class ForgotPasswordAlertContent extends StatefulWidget {
  ForgotPasswordAlertContent(this.fbKey, this.isLoading, this.isCodeSent);

  final GlobalKey<FormBuilderState> fbKey;
  final StreamController<bool>? isLoading;
  final StreamController<bool>? isCodeSent;

  @override
  _ForgotPasswordAlertContentState createState() =>
      _ForgotPasswordAlertContentState();
}

class _ForgotPasswordAlertContentState
    extends State<ForgotPasswordAlertContent> {
  bool? isLoading = false;

  @override
  Widget build(BuildContext context) {
    context.watch<LanguageController>();
    return Container(
      child: FormBuilder(
          key: widget.fbKey,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: 20),
                FormBuilderTextField(
                  keyboardType: TextInputType.phone,
                  cursorColor: Colors.black,
                  style: normalWhiteTextStyle,
                  name: 'phone',
                  decoration: InputDecoration(
                    labelText: 'Mobile_No'.tr(),
                    labelStyle: hintTextStyle,
                    contentPadding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                    border: OutlineInputBorder(
                        // borderRadius: BorderRadius.circular(10)
                        ),
                    focusedBorder: OutlineInputBorder(
                        //borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: secondary)),
                  ),
                  // validator: FormBuilderValidators.compose(
                  //   [
                  //     FormBuilderValidators.required(context),
                  //   ],
                  // ),
                ),
                SizedBox(height: 10),
                StreamBuilder<bool>(
                    stream: widget.isLoading!.stream,
                    initialData: false,
                    builder: (context, snapshot) {
                      return Visibility(
                          visible: snapshot.data!,
                          child: Center(
                            child: CircularProgressIndicator(),
                          ));
                    }),
                StreamBuilder<bool>(
                    stream: widget.isCodeSent!.stream,
                    initialData: false,
                    builder: (context, snapshot) {
                      return Visibility(
                          visible: snapshot.data!,
                          child: Column(
                            children: [
                              FormBuilderTextField(
                                cursorColor: secondary,
                                style: normalWhiteTextStyle,
                                name: 'code',
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(
                                  labelText: "ActivationCode".tr(),
                                  labelStyle: hintTextStyle,
                                  contentPadding:
                                      EdgeInsets.fromLTRB(20, 10, 20, 10),
                                  border: OutlineInputBorder(
                                      // borderRadius: BorderRadius.circular(10)
                                      ),
                                  focusedBorder: OutlineInputBorder(
                                      // borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(color: secondary)),
                                ),
                                // validator: FormBuilderValidators.compose(
                                //   [
                                //     FormBuilderValidators.required(context),
                                //   ],
                                // ),
                              ),
                              SizedBox(height: 10),
                              FormBuilderTextField(
                                cursorColor: secondary,
                                name: 'password',
                                style: normalWhiteTextStyle,
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(
                                  labelText: "Password".tr(),
                                  labelStyle: hintTextStyle,
                                  contentPadding:
                                      EdgeInsets.fromLTRB(20, 10, 20, 10),
                                  border: OutlineInputBorder(
                                      // borderRadius: BorderRadius.circular(10)
                                      ),
                                  focusedBorder: OutlineInputBorder(
                                      // borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(color: secondary)),
                                ),
                                obscureText: true,
                                // validator: FormBuilderValidators.compose(
                                //   [
                                //     FormBuilderValidators.required(context),
                                //   ],
                                // ),
                              ),
                              SizedBox(height: 10),
                              FormBuilderTextField(
                                cursorColor: secondary,
                                name: 'confirm_password',
                                style: normalWhiteTextStyle,
                                keyboardType: TextInputType.visiblePassword,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                decoration: InputDecoration(
                                  labelText: "CPassword".tr(),
                                  labelStyle: hintTextStyle,
                                  contentPadding:
                                      EdgeInsets.fromLTRB(20, 10, 20, 10),
                                  border: OutlineInputBorder(
                                      // borderRadius: BorderRadius.circular(10)
                                      ),
                                  focusedBorder: OutlineInputBorder(
                                      // borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(color: secondary)),
                                ),
                                obscureText: true,
                                // validator: FormBuilderValidators.compose(
                                //   [
                                //         (val) {
                                //       if (val !=
                                //           widget.fbKey.currentState
                                //               ?.fields['password']?.value) {
                                //         return 'Passwords do not match';
                                //       }
                                //       return null;
                                //     }
                                //   ],
                                // ),
                              ),
                            ],
                          ));
                    }),
              ])),
    );
  }
}
