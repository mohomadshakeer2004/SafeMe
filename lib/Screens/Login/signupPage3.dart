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
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../service/userService.dart';
import 'LoginPage.dart';
import 'package:firebase_storage/firebase_storage.dart';

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
  late GoogleMapController _googleMapController;
  Map<MarkerId, Marker> _markers = <MarkerId, Marker>{};

  final _auth = FirebaseAuth.instance;

  late UserService _userService;

  final databaseRef = FirebaseDatabase.instance.ref();

  var districts = ['Colombo', 'Gampaha', 'Galle'];
  var town = ['Veyangoda', 'Gampaha', 'Nittabwa', 'Pallewela', 'Kinawala'];

  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  final GlobalKey<FormBuilderState> _fbKeyValidation =
      GlobalKey<FormBuilderState>();

  final _txtNoController = TextEditingController();
  final _txtLine1Controller = TextEditingController();
  final _txtLine2Controller = TextEditingController();
  final _txtLocationController = TextEditingController();
  var _txtDistricController = TextEditingController();
  final _txtCityController = TextEditingController();

  late String district;
  late String city;

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
            // autovalidateMode: AutovalidateMode.onUserInteraction,
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
                            height: sysWidth / 100 * 40,
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
                              border: OutlineInputBorder(
                                  //   borderRadius: BorderRadius.circular(10)
                                  ),
                              focusedBorder: OutlineInputBorder(
                                  // borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: secondary)),
                            ),
                            // initialValue: allGroups[0],

                            items: districts
                                .map((district) => DropdownMenuItem(
                                      alignment:
                                          AlignmentDirectional.centerStart,
                                      value: district,
                                      child: Text(district),
                                    ))
                                .toList(),

                            validator: (value) =>
                                value == null ? "Enter Your District" : null,
                            onChanged: (val) => setState(() {
                              district = val.toString();
                            }),
                          ),
                          const SizedBox(height: 30),
                          FormBuilderDropdown(
                            validator: (value) =>
                                value == null ? "Enter Your City" : null,
                            onChanged: (val) => setState(() {
                              city = val.toString();
                            }),
                            name: 'town',
                            decoration: InputDecoration(
                              labelText: "City".tr(),
                              labelStyle: hintTextStyle,
                              contentPadding:
                                  const EdgeInsets.fromLTRB(20, 10, 20, 10),
                              border: OutlineInputBorder(
                                  //   borderRadius: BorderRadius.circular(10)
                                  ),
                              focusedBorder: OutlineInputBorder(
                                  // borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: secondary)),
                            ),
                            // initialValue: allGroups[0],

                            items: town
                                .map((town) => DropdownMenuItem(
                                      alignment:
                                          AlignmentDirectional.centerStart,
                                      value: town,
                                      child: Text(town),
                                    ))
                                .toList(),
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
                            validator: (value) => value!.isEmpty
                                ? 'Enter Your House Number'
                                : null,
                            decoration: InputDecoration(
                              labelText: "House_No".tr(),
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
                            name: "line2",
                            style: normalWhiteTextStyle,
                            keyboardType: TextInputType.text,
                            textCapitalization: TextCapitalization.words,
                            cursorColor: iconColor,
                            autofocus: false,
                            controller: _txtLine2Controller,
                            validator: (value) => value!.isEmpty
                                ? 'Enter Your Address Line 2'
                                : null,
                            decoration: InputDecoration(
                              labelText: "Address_L2".tr(),
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
                          InkWell(
                            onTap: () async {
                              if (_fbKey.currentState!.validate()) {
                                print("******Validate******");
                                EasyLoading.show(status: "Registering...");

                                late String address =
                                    "${_txtNoController.text} ${_txtLine1Controller.text} ${_txtLine2Controller.text}";
                                late String name =
                                    "${widget.fName} ${widget.lName}";

                                // var resp = await save(
                                //   "Chanuka Anuruddha1",
                                //   "97/8  VEYANGODA",
                                //   "vEYANGODA",
                                //   "gAMPAHA",
                                //   "CHANUKA@GMAIL.COM",
                                //   "0779873552",
                                //   "000000001V",
                                //   "Cha123",
                                //   "/data/user/0/com.safe_me.safe_me1/cache/171c8078-00cc-4ff3-a8a1-c6a7514f375c545932229824712967.jpg",
                                // );

                                var resp = await save(
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

                                MotionToast.success(
                                  title: Text("Success"),
                                  description: Text(
                                      "Your account has been created successfully!"),
                                  animationType: AnimationType.slideInFromTop,
                                  toastAlignment: Alignment.topCenter,
                                ).show(context);

                                EasyLoading.showSuccess('Great Success!');

                                Duration(seconds: 4);
                                print("******data Save******");
                                EasyLoading.dismiss();
                                Navigator.pop(context);

                                Future.delayed(Duration(milliseconds: 2500),
                                    () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => LoginPage()));
                                });

                                // Navigator.of(context).pushReplacement(
                                //     MaterialPageRoute(
                                //         builder: (_) => LoginPage()));
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
                    ),
                  ),
                );
              },
            )),
      ),
    );
  }

  Future<void> save(
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
    final databaseRef = FirebaseDatabase.instance.ref();
    FirebaseStorage storage = FirebaseStorage.instance;

    try {
      var data = {
        "Name": Name,
        "Address": Address,
        "City": City,
        "District": District,
        "Email": Email,
        "Mobile": Mobile,
        "NIC": NIC,
        "Password": Password,
        "ProfileImage": "",
      };

      /// Save User Data Step 1
      var response =
          databaseRef.child("/PublicUsers/All/").child(NIC).set(data);
      print(
          "**************Save User Data Step-1 response = ${response.toString()}");

      /// Save User step -2 Profile Image
      Reference ref = storage.ref().child("/public profile images/" + NIC);
      await ref.putFile(File(ProfileImage));
      String imageUrl = await ref.getDownloadURL();
      print("********Image URL = $imageUrl");

      ///Save User Data step - 3 update image Url
      databaseRef
          .child("/PublicUsers/All/$NIC")
          .update({'ProfileImage': imageUrl});

      ///Update User Count
      DatabaseReference ref1 =
          FirebaseDatabase.instance.ref("/PublicUsers/UserCount");
      DatabaseEvent event = await ref1.once();
      print(event.snapshot.value);

      int userCount = (event.snapshot.value) as int;
      databaseRef.child("/PublicUsers").update({'UserCount': userCount + 1});

    } catch (e) {
      return print(e);
    }
  }
}
