import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../Controller/language_controller.dart';
import '../Resources/colors.dart';
import '../Resources/style.dart';
import '../widgets/changePasswordAlert.dart';
import '../widgets/drawer.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _txtFNameController = TextEditingController();
  final _txtMobileNoController = TextEditingController();
  final _txtEmailController = TextEditingController();
  final _txtNicNoController = TextEditingController();
  final _txtAddressController = TextEditingController();

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  late List<int> profileImage;
  File? image;
  Map<String, dynamic> userData = {};
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

  getUserData() async {
    String nic = "951240999V";
    EasyLoading.show(status: "Getting User Data");
    final databaseRef = FirebaseDatabase.instance.ref();

    var get_UserData = databaseRef.child('/PublicUsers/All/').child(nic);
    DatabaseEvent event = await get_UserData.once();
    String aa = (event.snapshot.value).toString();
    Map<String, dynamic> data =
        jsonDecode(jsonEncode(event.snapshot.value)) as Map<String, dynamic>;
    setState(() {
      userData = data;

      _txtFNameController.text = userData['Name'];
      _txtEmailController.text = userData['Email'];
      _txtNicNoController.text = userData['NIC'];
      _txtMobileNoController.text = userData['Mobile'];
      _txtAddressController.text = userData['Address'];
    });

    print("************ User Data = ${data}**************");
    print("************  User Email = ${data['Email']}**************");
    EasyLoading.dismiss();
  }

  void _onRefresh() async {
    print("REFRESH STARTED");
    _refreshController.refreshCompleted();
    getUserData();
    print("REFRESH STOPPED");
  }

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<LanguageController>();
    double sysHeight = MediaQuery.of(context).size.height;
    double sysWidth = MediaQuery.of(context).size.width;
    double FontSize = MediaQuery.of(context).size.height / 100;

    return Scaffold(
      backgroundColor: Color(0xFFE7E7E7),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: mainBGColor,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: SvgPicture.asset(
                "assets/icons/menu.svg",
                height: sysWidth / 100 * 8,
                color: secondary,
              ),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
            );
          },
        ),
        title: Text(
          "Profile".tr(),
          style: TextStyle(fontSize: 22, color: iconColor),
        ),
      ),
      drawer: Drawer(
        child: DrawerWidget(),
      ),
      body: Container(
        // height: sysHeight,
        // width: sysWidth,
        child: Padding(
          padding: const EdgeInsets.only(top: 15, left: 15, right: 15),
          child: SmartRefresher(
            enablePullDown: true,
            // enablePullUp: true,
            header: WaterDropMaterialHeader(
              backgroundColor: secondary,
              color: mainBGColor,
            ),
            controller: _refreshController,
            onRefresh: _onRefresh,
            child: ListView(
              children: [
                Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    Column(
                      children: [
                        SizedBox(height: 60),
                        Container(
                          width: double.maxFinite,
                          //  height: 200, //sysHeight/100 *24,
                          height: sysHeight > sysWidth
                              ? sysHeight / 100 * 20
                              : sysWidth / 100 * 20,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: secondary,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 60),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  userData['Name'],
                                  style: TextStyle(
                                      color: normalTextColor,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Poppins-Light',
                                      fontSize: FontSize * 2.4),
                                ),
                                SizedBox(height: 3),
                                Text(
                                  userData['Email'],
                                  style: TextStyle(
                                      color: normalTextColor,
                                      fontFamily: 'Poppins-Light',
                                      fontSize: FontSize * 1.4),
                                ),
                                SizedBox(height: 5),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 46,
                              backgroundColor: secondary,
                              child: _imageFile != null
                                  ? getCircleAvatarWidget(
                                      FileImage(File(_imageFile!.path)))
                                  : CachedNetworkImage(
                                      imageUrl: userData['ProfileImage'],
                                      imageBuilder: (context, imageProvider) =>
                                          getCircleAvatarWidget(imageProvider),
                                      placeholder: (context, url) =>
                                          CircularProgressIndicator(),
                                      errorWidget: (context, url, error) =>
                                          getCircleAvatarWidget(
                                        AssetImage(
                                            "assets/images/no-profile.png"),
                                      ),
                                    ),
                            )
                          ],
                        )),
                  ],
                ),
                SizedBox(height: 15),
                Container(
                  //height: 250,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.white,
                  ),

                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          cursorColor: iconColor,
                          keyboardType: TextInputType.text,
                          controller: _txtFNameController,
                          decoration: InputDecoration(
                            labelText: "FulName".tr(),
                            labelStyle: hintTextStyle,
                            contentPadding:
                                const EdgeInsets.fromLTRB(20, 10, 20, 10),
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: secondary)),
                          ),
                        ),
                        SizedBox(height: 15),
                        // TextFormField(
                        //   cursorColor: iconColor,
                        //   keyboardType: TextInputType.text,
                        //   controller: _txtLNameController,
                        //   decoration: InputDecoration(
                        //     labelText: "LName".tr(),
                        //     labelStyle: hintTextStyle,
                        //     contentPadding:
                        //         const EdgeInsets.fromLTRB(20, 10, 20, 10),
                        //     border: OutlineInputBorder(),
                        //     focusedBorder: OutlineInputBorder(
                        //         borderSide: BorderSide(color: secondary)),
                        //   ),
                        // ),
                        SizedBox(height: 15),
                        TextFormField(
                          cursorColor: iconColor,
                          keyboardType: TextInputType.emailAddress,
                          controller: _txtEmailController,
                          decoration: InputDecoration(
                            labelText: "Email".tr(),
                            labelStyle: hintTextStyle,
                            contentPadding:
                                const EdgeInsets.fromLTRB(20, 10, 20, 10),
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: secondary)),
                          ),
                        ),
                        SizedBox(height: 15),
                        TextFormField(
                          readOnly: true,
                          cursorColor: iconColor,
                          keyboardType: TextInputType.text,
                          controller: _txtNicNoController,
                          decoration: InputDecoration(
                            labelText: "NIC".tr(),
                            labelStyle: hintTextStyle,
                            contentPadding:
                                const EdgeInsets.fromLTRB(20, 10, 20, 10),
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: secondary)),
                          ),
                        ),
                        SizedBox(height: 15),
                        TextFormField(
                          cursorColor: iconColor,
                          keyboardType: TextInputType.phone,
                          controller: _txtMobileNoController,
                          decoration: InputDecoration(
                            labelText: "Mobile_No".tr(),
                            labelStyle: hintTextStyle,
                            contentPadding:
                                const EdgeInsets.fromLTRB(20, 10, 20, 10),
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: secondary)),
                          ),
                        ),
                        SizedBox(height: 15),
                        TextFormField(
                          cursorColor: iconColor,
                          keyboardType: TextInputType.text,
                          controller: _txtAddressController,
                          decoration: InputDecoration(
                            labelText: "Address".tr(),
                            labelStyle: hintTextStyle,
                            contentPadding:
                                const EdgeInsets.fromLTRB(20, 10, 20, 10),
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: secondary)),
                          ),
                        ),
                        SizedBox(height: 30),
                        InkWell(
                          onTap: () async {
                            EasyLoading.show(status: "Saving data...");

                            var result = await updateProfile(
                                userData['NIC'],
                                _txtFNameController.text,
                                _txtAddressController.text,
                                _txtEmailController.text,
                                _txtMobileNoController.text,
                                userData['ProfileImage'],
                                _imageFile!.path.toString());

                            if (result = true) {
                              EasyLoading.dismiss();
                              EasyLoading.showSuccess(
                                  'Profile Updated Successfully!');

                              Future.delayed(Duration(milliseconds: 3500),
                              () {
                                print("******Profile Updated successfully!******");
                                _onRefresh();
                              },);

                            }
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
                                  "Save".tr(),
                                  style: buttonTextStyle,
                                )
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 15),
                        InkWell(
                          onTap: () async {
                            print('Pressed Change password');
                            ChangePasswordAlert().getAlert(context).show();
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
                                  "ChangePassword".tr(),
                                  style: buttonTextStyle,
                                )
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 15),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
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

  Future<void> updateProfile(
    String NIC,
    String Name,
    String Address,
    String Email,
    String Mobile,
    String oldProImage,
    String ProfileImage,
  ) async {
    final databaseRef = FirebaseDatabase.instance.ref();
    FirebaseStorage storage = FirebaseStorage.instance;

    try {
      var data = {
        "Name": Name,
        "Address": Address,
        "Email": Email,
        "Mobile": Mobile,
        // "ProfileImage": imageUrl,
      };

      databaseRef.child("/PublicUsers/All/$NIC").update(data);
    } catch (e) {
      return print(e);
    }
  }
}
