import 'dart:io';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:motion_toast/resources/arrays.dart';
import 'package:provider/provider.dart';
import '../../Controller/language_controller.dart';
import '../../Resources/colors.dart';
import '../../Resources/style.dart';
import '../../data/sri_lanka_locations.dart';
import '../../service/firebase_service.dart';
import '../../service/storage_service.dart';
import 'LoginPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignupScreen3 extends StatefulWidget {
  SignupScreen3(this.fName, this.lName, this.NIC, this.mobileNo, this.email,
      this.image, this.password);

  final String fName;
  final String lName;
  final String NIC;
  final String mobileNo;
  final String email;
  final String image;
  final String password;

  @override
  _SignupScreen3State createState() => _SignupScreen3State();
}

class _SignupScreen3State extends State<SignupScreen3> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();

  final _txtNoController = TextEditingController();
  final _txtLine1Controller = TextEditingController();
  final _txtLine2Controller = TextEditingController();

  String district = '';
  String city = '';

  @override
  void dispose() {
    _txtNoController.dispose();
    _txtLine1Controller.dispose();
    _txtLine2Controller.dispose();
    super.dispose();
  }

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
          color: buttonColor,
        ),
      ),
      body: SafeArea(
        child: FormBuilder(
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
                    "Address".tr(),
                    style: TextStyle(
                      fontSize: 30,
                      color: textBlackColor,
                      fontFamily: 'Poppins-Regular',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Address_txt".tr(),
                    style: TextStyle(
                      fontSize: 18,
                      color: textBlackColor,
                      fontFamily: 'Poppins-Light',
                    ),
                  ),
                  const SizedBox(height: 30),
                  FormBuilderDropdown(
                    name: 'district',
                    decoration: InputDecoration(
                      labelText: "district".tr(),
                      labelStyle: hintTextStyle,
                      contentPadding:
                          const EdgeInsets.fromLTRB(20, 10, 20, 10),
                      border: const OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: secondary)),
                    ),
                    items: SriLankaLocations.dropdownItems(
                      SriLankaLocations.districts,
                    ),
                    validator: (value) =>
                        value == null || value.toString().isEmpty
                            ? "Enter Your District"
                            : null,
                    onChanged: (val) => setState(() {
                      district = val?.toString() ?? '';
                      city = '';
                      _fbKey.currentState?.fields['town']?.didChange(null);
                    }),
                  ),
                  const SizedBox(height: 30),
                  FormBuilderDropdown(
                    key: ValueKey('city_$district'),
                    enabled: district.isNotEmpty,
                    validator: (value) =>
                        value == null || value.toString().isEmpty
                            ? "Enter Your City"
                            : null,
                    onChanged: (val) => setState(() {
                      city = val?.toString() ?? '';
                    }),
                    name: 'town',
                    decoration: InputDecoration(
                      labelText: "City".tr(),
                      labelStyle: hintTextStyle,
                      contentPadding:
                          const EdgeInsets.fromLTRB(20, 10, 20, 10),
                      border: const OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: secondary)),
                    ),
                    items: SriLankaLocations.dropdownItems(
                      SriLankaLocations.citiesForDistrict(district),
                    ),
                  ),
                  const SizedBox(height: 30),
                  FormBuilderTextField(
                    name: "no",
                    style: normalWhiteTextStyle,
                    textCapitalization: TextCapitalization.words,
                    keyboardType: TextInputType.text,
                    cursorColor: iconColor,
                    autofocus: false,
                    controller: _txtNoController,
                    validator: (value) =>
                        value!.isEmpty ? 'Enter Your House Number' : null,
                    decoration: InputDecoration(
                      labelText: "House_No".tr(),
                      labelStyle: hintTextStyle,
                      contentPadding:
                          const EdgeInsets.fromLTRB(20, 10, 20, 10),
                      border: const OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: secondary)),
                    ),
                  ),
                  const SizedBox(height: 30),
                  FormBuilderTextField(
                    name: "line1",
                    style: normalWhiteTextStyle,
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.words,
                    cursorColor: iconColor,
                    autofocus: false,
                    controller: _txtLine1Controller,
                    validator: (value) => value!.isEmpty ? null : null,
                    decoration: InputDecoration(
                      labelText: "Address_L1".tr(),
                      labelStyle: hintTextStyle,
                      contentPadding:
                          const EdgeInsets.fromLTRB(20, 10, 20, 10),
                      border: const OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: secondary)),
                    ),
                  ),
                  const SizedBox(height: 30),
                  FormBuilderTextField(
                    name: "line2",
                    style: normalWhiteTextStyle,
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.words,
                    cursorColor: iconColor,
                    autofocus: false,
                    controller: _txtLine2Controller,
                    validator: (value) =>
                        value!.isEmpty ? 'Enter Your Address Line 2' : null,
                    decoration: InputDecoration(
                      labelText: "Address_L2".tr(),
                      labelStyle: hintTextStyle,
                      contentPadding:
                          const EdgeInsets.fromLTRB(20, 10, 20, 10),
                      border: const OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: secondary)),
                    ),
                  ),
                  const SizedBox(height: 30),
                  InkWell(
                    onTap: () async {
                      if (!_fbKey.currentState!.validate()) {
                        print("******Not Validate******");
                        return;
                      }
                      if (district.isEmpty || city.isEmpty) {
                        MotionToast.error(
                          title: const Text("Error"),
                          description: const Text(
                            "Please select District and City",
                          ),
                          animationType: AnimationType.slideInFromTop,
                          toastAlignment: Alignment.topCenter,
                        ).show(context);
                        return;
                      }

                      print("******Validate******");
                      EasyLoading.show(status: "Registering...");

                      final address =
                          "${_txtNoController.text} ${_txtLine1Controller.text} ${_txtLine2Controller.text}";
                      final name = "${widget.fName} ${widget.lName}";

                      final result = await save(
                        name,
                        address,
                        city,
                        district,
                        widget.email,
                        widget.mobileNo,
                        widget.NIC,
                        widget.password,
                        widget.image,
                      );

                      EasyLoading.dismiss();
                      if (!mounted) return;

                      if (result == 'duplicate') {
                        MotionToast.error(
                          title: const Text("NIC already registered"),
                          description: Text(
                            "This NIC (${widget.NIC}) is already used. "
                            "Please sign in instead.",
                          ),
                          animationType: AnimationType.slideInFromTop,
                          toastAlignment: Alignment.topCenter,
                        ).show(context);
                        return;
                      }

                      if (result != 'ok') {
                        MotionToast.error(
                          title: const Text("Registration failed"),
                          description: const Text(
                            "Could not create your account. Check connection and try again.",
                          ),
                          animationType: AnimationType.slideInFromTop,
                          toastAlignment: Alignment.topCenter,
                        ).show(context);
                        return;
                      }

                      print("******data Save******");
                      MotionToast.success(
                        title: const Text("Success"),
                        description: const Text(
                            "Your account has been created successfully!"),
                        animationType: AnimationType.slideInFromTop,
                        toastAlignment: Alignment.topCenter,
                      ).show(context);

                      await Future.delayed(const Duration(milliseconds: 1500));
                      if (!mounted) return;
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => LoginPage()),
                        (route) => false,
                      );
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
                            "Sign_Up".tr(),
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
                          Navigator.pop(context);
                          Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (_) => LoginPage()));
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
            )),
      ),
    );
  }

  /// Returns `ok`, `duplicate`, or `error`.
  Future<String> save(
    String Name,
    String Address,
    String City,
    String District,
    String Email,
    String Mobile,
    String NIC,
    String Password,
    String ProfileImage,
  ) async {
    final nicKey = NIC.trim().toUpperCase();

    try {
      await FirebaseService.instance.signInAsAdmin();
    } on FirebaseAuthException catch (e) {
      print('Auth signup failed (${e.code}): ${e.message}');
      return 'error';
    } catch (e) {
      print('Auth signup failed: $e');
      return 'error';
    }

    try {
      final taken = await FirebaseService.instance.isNicRegistered(nicKey);
      if (taken) {
        return 'duplicate';
      }
    } catch (e) {
      print('NIC uniqueness check failed: $e');
      return 'error';
    }

    final databaseRef = FirebaseService.instance.rootRef;

    try {
      final data = {
        "Name": Name,
        "Address": Address,
        "City": City,
        "District": District,
        "Email": Email,
        "Mobile": Mobile,
        "NIC": nicKey,
        "Password": Password,
        "ProfileImage": "",
      };

      await databaseRef.child("/PublicUsers/All/").child(nicKey).set(data);
      print("**************Save User Data Step-1 OK $nicKey");

      final imageUrl = await StorageService.uploadFileOrInline(
        storagePath: 'public-profile/$nicKey.jpg',
        file: File(ProfileImage),
        contentType: 'image/jpeg',
        timeout: const Duration(seconds: 45),
      );
      if (imageUrl != null) {
        print("********Image URL = $imageUrl");
        await databaseRef
            .child("/PublicUsers/All/$nicKey")
            .update({'ProfileImage': imageUrl});
      } else {
        print('Profile image upload skipped/failed for $nicKey');
      }

      DatabaseReference ref1 =
          FirebaseService.instance.rootRef.child("/PublicUsers/UserCount");
      DatabaseEvent event = await ref1.once();
      print(event.snapshot.value);

      final rawCount = event.snapshot.value;
      final userCount = rawCount is int
          ? rawCount
          : int.tryParse('$rawCount') ?? 0;
      await databaseRef
          .child("/PublicUsers")
          .update({'UserCount': userCount + 1});

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        FirebaseService.loggedInNicKey,
        nicKey,
      );
      return 'ok';
    } catch (e) {
      print(e);
      return 'error';
    }
  }
}
