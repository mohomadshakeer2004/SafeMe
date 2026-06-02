import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:motion_toast/resources/arrays.dart';
import 'package:provider/provider.dart';
import 'package:motion_toast/motion_toast.dart';
import '../../Controller/language_controller.dart';
import '../../Resources/colors.dart';
import '../../Resources/style.dart';
import 'LoginPage.dart';
import 'signupPage2.dart';

class SignupScreen1 extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen1> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  final GlobalKey<FormBuilderState> _fbKeyValidation =
      GlobalKey<FormBuilderState>();

  late List<int> profileImage;
  File? image;

  XFile? _imageFile = null;
  final ImagePicker _picker = ImagePicker();

  getCircleAvatarWidget(ImageProvider<Object> imageProvider) {
    return CircleAvatar(
      radius: 43,
      backgroundColor: Colors.white,
      backgroundImage: imageProvider,
      child: Align(
        alignment: Alignment.bottomRight,
        child: InkWell(
          onTap: () {
            showModalBottomSheet(
              context: context,
              builder: ((build) => bottomSheet()),
            );
          },
          child: CircleAvatar(
            backgroundColor: Colors.white,
            radius: 12.0,
            child: Icon(
              Icons.camera_alt,
              size: 15.0,
              color: secondary,
            ),
          ),
        ),
      ),
    );
  }

  final _txtFNameController = TextEditingController();
  final _txtLNameController = TextEditingController();
  final _txtEmailController = TextEditingController();
  final _txtMobNoController = TextEditingController();
  final _txtNicController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    context.watch<LanguageController>();
    double sysHeight = MediaQuery.of(context).size.height;
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
            //autovalidateMode: AutovalidateMode.onUserInteraction,
            key: _fbKey,
            child: Builder(
              builder: (context) {
                return SizedBox(
                  width: sysWidth,
                  height: sysHeight,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 15, right: 15),
                    child: Center(
                      child: ListView(
                        children: [
                          Image.asset(
                            "assets/images/logo.png",
                            height: sysWidth / 100 * 30,
                          ),
                          const SizedBox(height: 40),
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              "Welcome".tr(),
                              style: TextStyle(
                                fontSize: 25,
                                color: textBlackColor,
                                fontFamily: 'Poppins-Regular',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              "Sign_Up_txt".tr(),
                              style: TextStyle(
                                fontSize: 16,
                                color: textBlackColor,
                                fontFamily: 'Poppins-Light',
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          CircleAvatar(
                            radius: 46,
                            backgroundColor: secondary,
                            child: _imageFile != null
                                ? getCircleAvatarWidget(
                                    FileImage(File(_imageFile!.path)))
                                : getCircleAvatarWidget(
                                    AssetImage("assets/images/no-profile.png"),
                                  ),
                          ),
                          const SizedBox(height: 30),
                          FormBuilderTextField(
                            textCapitalization: TextCapitalization.words,
                            name: "fName",
                            style: normalWhiteTextStyle,
                            keyboardType: TextInputType.name,
                            cursorColor: iconColor,
                            autofocus: false,
                            controller: _txtFNameController,
                            validator: (value) => value!.isEmpty
                                ? 'Enter Your First Name'
                                : (RegExp(r'[!@#<>?":_`~;[\]\\|=+)(*&^%0-9-]'))
                                        .hasMatch(value)
                                    ? 'Enter a Valid Name'
                                    : null,

                            //     (value){
                            //   if(value!.isEmpty){
                            //     return ("Please Enter Your First Name");
                            //   }
                            //   if(value!.characters.){
                            //
                            //   }
                            // },
                            decoration: InputDecoration(
                              contentPadding:
                                  const EdgeInsets.fromLTRB(20, 10, 20, 10),
                              border: OutlineInputBorder(
                                  // borderRadius: BorderRadius.circular(10)
                                  ),
                              focusedBorder: OutlineInputBorder(
                                  //  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: secondary)),
                              labelText: "FName".tr(),
                              labelStyle: hintTextStyle,
                            ),
                          ),
                          const SizedBox(height: 30),
                          FormBuilderTextField(
                            name: "lName",
                            style: normalWhiteTextStyle,
                            textCapitalization: TextCapitalization.words,
                            keyboardType: TextInputType.name,
                            autofocus: false,
                            controller: _txtLNameController,
                            validator: (value) => value!.isEmpty
                                ? 'Enter Your Last Name'
                                : (RegExp(r'[!@#<>?":_`~;[\]\\|=+)(*&^%0-9-]'))
                                        .hasMatch(value)
                                    ? 'Enter a Valid Name'
                                    : null,
                            decoration: InputDecoration(
                              labelText: "LName".tr(),
                              labelStyle: hintTextStyle,
                              contentPadding:
                                  const EdgeInsets.fromLTRB(20, 10, 20, 10),
                              border: OutlineInputBorder(
                                  // borderRadius: BorderRadius.circular(10)
                                  ),
                              focusedBorder: OutlineInputBorder(
                                  //  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: secondary)),
                            ),
                          ),
                          const SizedBox(height: 30),
                          FormBuilderTextField(
                            name: "nic",
                            style: normalWhiteTextStyle,
                            textCapitalization: TextCapitalization.characters,
                            keyboardType: TextInputType.text,
                            autofocus: false,
                            controller: _txtNicController,
                            validator: (value) => value!.isEmpty
                                ? 'Enter Your NIC No'
                                : (RegExp(r'[!@#<>?":_`~;[\]\\|=+)]'))
                                        .hasMatch(value)
                                    ? 'Enter a Valid NIC No'
                                    : null,
                            decoration: InputDecoration(
                              labelText: "NIC".tr(),
                              labelStyle: hintTextStyle,
                              contentPadding:
                                  EdgeInsets.fromLTRB(20, 10, 20, 10),
                              border: OutlineInputBorder(
                                  // borderRadius: BorderRadius.circular(10)
                                  ),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: secondary)),
                            ),
                          ),
                          const SizedBox(height: 30),
                          FormBuilderTextField(
                            name: "email",
                            style: normalWhiteTextStyle,
                            keyboardType: TextInputType.emailAddress,
                            autofocus: false,
                            controller: _txtEmailController,
                            validator: (value) => value!.isEmpty
                                ? 'Enter Your email'
                                : (RegExp(r'^.+@[a-zA-Z]+\.{1}[a-zA-Z]+(\.{0,1}[a-zA-Z]+)$'))
                                        .hasMatch(value)
                                    ? null
                                    : 'Enter a Valid email',
                            decoration: InputDecoration(
                              labelText: "Email".tr(),
                              labelStyle: hintTextStyle,
                              contentPadding:
                                  EdgeInsets.fromLTRB(20, 10, 20, 10),
                              border: OutlineInputBorder(
                                  // borderRadius: BorderRadius.circular(10)
                                  ),
                              focusedBorder: OutlineInputBorder(
                                  //   borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: secondary)),
                            ),
                          ),
                          const SizedBox(height: 30),
                          FormBuilderTextField(
                            name: "mobile",
                            style: normalWhiteTextStyle,
                            keyboardType: TextInputType.phone,
                            autofocus: false,
                            maxLength: 10,
                            controller: _txtMobNoController,
                            validator: (value) => value!.isEmpty
                                ? 'Enter Your Mobile Number'
                                : value.length == 10
                                    ? null
                                    : 'Enter Valid Mobile Number',
                            decoration: InputDecoration(
                              labelText: "Mobile_No".tr(),
                              labelStyle: hintTextStyle,
                              contentPadding:
                                  EdgeInsets.fromLTRB(20, 10, 20, 10),
                              border: OutlineInputBorder(
                                  //  borderRadius: BorderRadius.circular(10)
                                  ),
                              focusedBorder: OutlineInputBorder(
                                  // borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: secondary)),
                            ),
                          ),
                          const SizedBox(height: 30),
                          InkWell(
                            onTap: () async {
                              if (_fbKey.currentState!.validate()) {
                                if (_imageFile != null) {
                                  print("******Validate******");
                                  print(_fbKey.currentState!.value);
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SignupScreen2(
                                            _txtFNameController.text,
                                            _txtLNameController.text,
                                            _txtNicController.text,
                                            _txtMobNoController.text,
                                            _txtEmailController.text,
                                            _imageFile!.path.toString()),
                                      ));
                                } else {
                                  MotionToast.error(
                                    title: Text("Error"),
                                    description: Text(
                                        "Please Select your Profile Image"),
                                    animationType: AnimationType.slideInFromLeft,
                                    toastAlignment: Alignment.topCenter,
                                  ).show(context);
                                }
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
                          const SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Already_have_an_account".tr(),
                                style: blackNormalTextStyle,
                              ),
                              InkWell(
                                onTap: () {
                                  print('Pressed  Login');
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => LoginPage(),
                                      ));
                                },
                                child: Text(
                                  "Login".tr(),
                                  style: blackNormalBoldTextStyle,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 40),
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

  Widget bottomSheet() {
    return Container(
      height: 100.0,
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.only(left: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            InkWell(
              onTap: () {
                takePhoto(ImageSource.camera);
              },
              child: Row(
                children: [
                  Icon(
                    Icons.camera_alt,
                    color: IconColor2,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(
                      "Camera",
                      style: TextStyle(
                        fontSize: 15,
                        color: IconColor2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: () {
                takePhoto(ImageSource.gallery);
              },
              child: Row(
                children: [
                  Icon(
                    Icons.image,
                    color: IconColor2,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(
                      "Gallery",
                      style: TextStyle(
                        fontSize: 15,
                        color: IconColor2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void takePhoto(ImageSource source) async {
    final pickedFile = await _picker.pickImage(
      source: source,
    );
    setState(() {
      if (pickedFile != null) {
        _imageFile = pickedFile;
      }
    });
  }
}
