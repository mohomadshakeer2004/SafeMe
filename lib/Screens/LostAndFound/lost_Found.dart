import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:safe_me/service/firebase_service.dart';
import 'package:safe_me/service/storage_service.dart';
import 'package:safe_me/service/userService.dart';
import 'package:safe_me/util/user_data_util.dart';
import 'package:image_picker/image_picker.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:motion_toast/resources/arrays.dart';
import 'package:provider/provider.dart';

import '../../Controller/language_controller.dart';
import '../../Resources/colors.dart';
import '../../Resources/style.dart';
import '../../widgets/drawer.dart';
import '../../widgets/safe_date_field.dart';
import '../home_base.dart';

class LostFoundItem extends StatefulWidget {
  const LostFoundItem({Key? key}) : super(key: key);

  @override
  _LostFoundItemState createState() => _LostFoundItemState();
}

class _LostFoundItemState extends State<LostFoundItem> {
  bool isVideo = false;
  File? _file1;
  File? _file2;
  bool LostAndFound = false;
  bool isAgree = false;
  Map<String, dynamic> userData = {};
  Position _position = Position(
      longitude: 0,
      latitude: 0,
      timestamp: DateTime.fromMillisecondsSinceEpoch(0),
      accuracy: 0,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0);

  takePhoto(ImageSource source) async {
    final img = await ImagePicker().pickImage(
      source: source,
    );

    setState(() {
      if (img != null) {
        _file1 == null ? _file1 = File(img.path) : _file2 = File(img.path);
      }
    });
  }

  pickPhoto(ImageSource source) async {
    final img = await FilePicker.platform.pickFiles(type: FileType.image);
    PlatformFile file = img!.files.first;
    // _file = File(file.path!);
    setState(() {
      _file1 == null ? _file1 = File(file.path!) : _file2 = File(file.path!);
    });

    // _videoPlayerController = VideoPlayerController.file(_file!)
    //   ..initialize().then((_) {
    //     setState(() {
    //       _videoPlayerController.play();
    //     });
    //   }
    //   );
  }

  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  final GlobalKey<FormBuilderState> _fbKeyValidation =
      GlobalKey<FormBuilderState>();
  TextEditingController _txtLocation = TextEditingController();

  var districts = ['Ampara','Anuradhapura','Badulla','Batticaloa', 'Colombo','Galle',
    'Gampaha','Hambantota','Jaffna', 'Kalutara','Kandy', 'Kegalle', 'Hambantota', 'Kegalle' ];

  var city = ['Gampaha','Veyangoda','Minuwangoda', 'Nittabuwa', 'Aththnagalla','Kaduwela','Kolonnawa', 'Maharagama','Kesbewa','Nugegoda','Ahangama', 'Ambalangoda' ,'Balapitiya' ];


  String selectDistrict = '';
  String selectCity = '';
  DateTime selectDate = DateTime.now();

  getCurrLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }

      final positionCur = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (!mounted) return;
      setState(() {
        _position = positionCur;
        _txtLocation.text =
            "${positionCur.latitude.toStringAsFixed(7)} , ${positionCur.longitude.toStringAsFixed(7)}";
      });
    } catch (e) {
      debugPrint('Location unavailable: $e');
    }
  }

  getUserData() async {
    final nic = await UserService().requireLoggedInNic();
    if (nic == null) return;
    EasyLoading.show(status: "Getting User Data");
    try {
      final databaseRef = FirebaseService.instance.rootRef;
      final event =
          await databaseRef.child('/PublicUsers/All/').child(nic).once();

      if (event.snapshot.value == null) return;

      final data = UserDataUtil.withDefaults(
        jsonDecode(jsonEncode(event.snapshot.value)) as Map<String, dynamic>,
        nic,
      );
      if (!mounted) return;
      setState(() {
        userData = data;
      });
    } catch (e) {
      debugPrint('Failed to load user data: $e');
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<void> _initScreen() async {
    await getUserData();
    await getCurrLocation();
  }

  final _txtDescriptionController = TextEditingController();

  // final _txtSubjectController = TextEditingController();
  // final _txtSubjectController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initScreen();
  }

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
          "Lost_Found".tr(),
          style: TextStyle(
              fontSize: 18,
              color: secondary,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins-Light'),
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
              color: primaryColor,
              size: 30,
            ),
            onPressed: () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const HomeBase()));
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: DrawerWidget(),
      ),
      body: FormBuilder(
        key: _fbKey,
        child: Builder(builder: (context) {
          return Container(
            width: sysWidth,
            height: sysHeight,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: ListView(
                children: [
                  SizedBox(height: 15),
                  FormBuilderDropdown(
                    onChanged: (val) => setState(() {
                      selectDistrict = val.toString();
                    }),
                    name: 'district',
                    decoration: InputDecoration(
                      labelText: "district".tr(),
                      labelStyle: hintTextStyle,
                      contentPadding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: secondary)),
                    ),
                    // initialValue: allGroups[0],
                    validator: (value) =>
                        value == null ? "Enter Your District" : null,

                    items: districts
                        .map((district) => DropdownMenuItem(
                              alignment: AlignmentDirectional.centerStart,
                              value: district,
                              child: Text(district),
                            ))
                        .toList(),
                  ),
                  SizedBox(height: 15),
                  FormBuilderDropdown(
                    onChanged: (val) => setState(() {
                      selectCity = val.toString();
                    }),
                    name: 'city',
                    decoration: InputDecoration(
                      labelText: "City".tr(),
                      labelStyle: hintTextStyle,
                      contentPadding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: secondary)),
                    ),
                    validator: (value) =>
                        value == null ? "Enter Your City" : null,
                    // initialValue: allGroups[0],

                    items: city
                        .map((city) => DropdownMenuItem(
                              alignment: AlignmentDirectional.centerStart,
                              value: city,
                              child: Text(city),
                            ))
                        .toList(),
                  ),
                  SizedBox(height: 15),
                  SafeDateField(
                    name: 'dateTime',
                    labelText: "DateTime".tr(),
                    labelStyle: hintTextStyle,
                    focusColor: secondary,
                    includeTime: true,
                    lastDate: DateTime.now(),
                    firstDate: DateTime.now().subtract(const Duration(days: 5)),
                    onChanged: (val) => setState(() {
                      if (val != null) selectDate = val;
                    }),
                    validator: (value) => value == null
                        ? "Enter Lost or Found Date & Time"
                        : null,
                  ),
                  SizedBox(height: 15),
                  FormBuilderTextField(
                    cursorColor: secondary,
                    minLines: 5,
                    maxLines: 15,
                    name: 'description',
                    controller: _txtDescriptionController,
                    decoration: InputDecoration(
                      labelText: "Description".tr(),
                      labelStyle: hintTextStyle,
                      contentPadding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: secondary)),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Description is Required' : null,
                  ),
                  SizedBox(height: 25),
                  Text(
                    "SelectImages".tr(),
                    style: TextStyle(
                        // fontSize: 20,
                        color: tilsTextColor,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins-Light'),
                  ),
                  SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      InkWell(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            builder: ((build) => bottomSheet()),
                          );
                        },
                        child: Container(
                          height: sysWidth / 4,
                          width: sysWidth / 4,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.black45,
                              width: 1,
                            ),
                          ),
                          child: _file1 == null
                              ? Image.asset(
                                  "assets/images/no_media.png",
                                  height: sysWidth / 4,
                                  width: sysWidth / 4,
                                  fit: BoxFit.cover,
                                )
                              : Image.file(_file1!,
                                  fit: BoxFit.fill, height: 20),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            builder: ((build) => bottomSheet()),
                          );
                        },
                        child: Container(
                          height: sysWidth / 4,
                          width: sysWidth / 4,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.black45,
                              width: 1,
                            ),
                          ),
                          child: _file2 == null
                              ? Image.asset(
                                  "assets/images/no_media.png",
                                  height: sysWidth / 4,
                                  width: sysWidth / 4,
                                  fit: BoxFit.cover,
                                )
                              : Image.file(_file2!,
                                  fit: BoxFit.fill, height: 20),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  FormBuilderCheckbox(
                    onChanged: (val) => setState(() {
                      isAgree = true;
                    }),
                    name: 'accept_terms',
                    initialValue: false,
                    activeColor: secondary,
                    // onChanged: _onChanged,
                    title: Text(
                      "Terms_Conditions".tr(),
                      style: TextStyle(color: textBlackColor),
                    ),
                  ),
                  SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                          onTap: () async {
                            try {
                              if (_fbKey.currentState!.saveAndValidate() &&
                                  _file1 != null &&
                                  _file2 != null) {
                                final formData = _fbKey.currentState!.value;
                                final agreed = formData['accept_terms'] == true;
                                if (agreed) {
                                  final district =
                                      formData['district'] as String? ?? '';
                                  final city =
                                      formData['city'] as String? ?? '';
                                  final date = formData['dateTime'] as DateTime? ??
                                      selectDate;
                                  final description =
                                      formData['description'] as String? ??
                                          _txtDescriptionController.text;

                                  EasyLoading.show(status: "Submitting...");
                                  print("******Validate******");
                                  bool result = false;
                                  try {
                                    result = await submitLostAndFound(
                                      UserDataUtil.field(userData, 'Address'),
                                      city,
                                      date,
                                      description,
                                      district,
                                      UserDataUtil.field(userData, 'Email'),
                                      _file1!,
                                      _file2!,
                                      _position.latitude,
                                      _position.longitude,
                                      UserDataUtil.mobileAsInt(userData),
                                      UserDataUtil.field(userData, 'NIC'),
                                      UserDataUtil.field(userData, 'Name'),
                                      UserDataUtil.field(
                                          userData, 'ProfileImage'),
                                    );
                                  } finally {
                                    EasyLoading.dismiss();
                                  }

                                  if (result) {
                                    EasyLoading.showSuccess(
                                        'Lost and Found Complaint Submitted successfully!',
                                        duration: Duration(seconds: 5));
                                    print(
                                        "******Complaint Submitted successfully!******");
                                    if (!context.mounted) return;
                                    Navigator.pop(context);
                                    Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => HomeBase()),
                                        (route) => false);
                                  } else {
                                    EasyLoading.showError(
                                        "Lost and Found Complaint Submitted Failed");
                                  }
                                } else {
                                  MotionToast.error(
                                    title: Text("Error"),
                                    description: Text(
                                        "Please Agree to Terms & Condition"),
                                    animationType: AnimationType.slideInFromLeft,
                                    toastAlignment: Alignment.topCenter,
                                  ).show(context);
                                }
                              } else {
                                print("******Not Validate******");
                                MotionToast.error(
                                  title: Text("Error"),
                                  description:
                                      Text("Please Select Evidence Images"),
                                  animationType: AnimationType.slideInFromLeft,
                                  toastAlignment: Alignment.topCenter,
                                ).show(context);
                              }
                            } catch (e) {
                              print(e);
                              EasyLoading.dismiss();
                              print("******Not Validate******");
                            }
                          },
                          child: Container(
                            height: 50,
                            width: sysWidth / 3 * 2,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(3),
                              color: buttonColor,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "Submit".tr(),
                                  style: buttonTextStyle,
                                ),
                                Icon(
                                  Icons.upload_file_outlined,
                                  color: normalTextColor,
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                  SizedBox(height: 15),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget bottomSheet() {
    double sysHeight = MediaQuery.of(context).size.height;
    double sysWidth = MediaQuery.of(context).size.width;
    return Container(
      height: sysHeight / 4,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "ChooseFrom".tr(),
              style: TextStyle(
                  fontSize: 20,
                  color: secondary,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins-Bold'),
            ),
            //SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      takePhoto(ImageSource.camera);
                    },
                    child: Container(
                        height: sysHeight / 8 * 0.7,
                        width: sysHeight / 8 * 0.7,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(3),
                            boxShadow: const [
                              BoxShadow(blurRadius: 1, color: Colors.black45)
                            ]),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.camera_alt_outlined,
                              color: secondary,
                              // size: sysWidth / 15 * 1,
                            ),
                            Text(
                              "Camera".tr(),
                              style: TextStyle(
                                  // / fontSize: 20,
                                  color: secondary,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Poppins-Light'),
                            ),
                          ],
                        )),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      pickPhoto(ImageSource.gallery);
                    },
                    child: Container(
                      height: sysHeight / 8 * 0.7,
                      width: sysHeight / 8 * 0.7,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(3),
                          boxShadow: const [
                            BoxShadow(blurRadius: 1, color: Colors.black45)
                          ]),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_outlined,
                            color: secondary,
                            // size: sysWidth / 15 * 1,
                          ),
                          Text(
                            "Gallery".tr(),
                            style: TextStyle(
                                // / fontSize: 20,
                                color: secondary,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins-Light'),
                          ),
                        ],
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

  Future<bool> submitLostAndFound(
    String Address,
    String City,
    DateTime Date,
    String Description,
    String District,
    String Email,
    File Image1,
    File Image2,
    double Latitude,
    double Longitude,
    int Mobile,
    String NIC,
    String Name,
    String ProfileImage,
  ) async {
    final firebase = FirebaseService.instance;
    final timeout = FirebaseService.rtdbTimeout;

    try {
      await firebase.ensureAuthenticatedForWrite();
      final databaseRef = firebase.rootRef;

      final cidEvent = await databaseRef
          .child("/Complaints/lastCID")
          .once()
          .timeout(timeout);
      var cid = int.tryParse('${cidEvent.snapshot.value}') ?? 0;
      cid++;

      print("************ Lost and Found Complaint ID = $cid**************");

      final data = {
        "CID": cid,
        "Address": Address,
        "City": City,
        "Date": Date.toString(),
        "Description": Description,
        "District": District,
        "Email": Email,
        "Image1": "",
        "Image2": "",
        "Latitude": Latitude,
        "Longitude": Longitude,
        "Mobile": Mobile,
        "NIC": NIC,
        "Name": Name,
        "ProfileImage": ProfileImage,
        "Reason": "",
        "Status": "Pending",
        "Type": "Lost And Found",
      };

      await databaseRef
          .child("/Complaints/All/$cid")
          .set(data)
          .timeout(timeout);
      print("**************Save Lost and Found response ");

      await databaseRef
          .child("/Complaints/lastCID")
          .set(cid)
          .timeout(timeout);

      final countEvent = await databaseRef
          .child("/Complaints/ComplaintCount")
          .once()
          .timeout(timeout);
      final count = int.tryParse('${countEvent.snapshot.value}') ?? 0;
      await databaseRef
          .child("/Complaints/ComplaintCount")
          .set(count + 1)
          .timeout(timeout);

      final lfEvent = await databaseRef
          .child("/Complaints/LostAndFoundCount")
          .once()
          .timeout(timeout);
      final lfCount = int.tryParse('${lfEvent.snapshot.value}') ?? 0;
      await databaseRef
          .child("/Complaints/LostAndFoundCount")
          .set(lfCount + 1)
          .timeout(timeout);

      _uploadComplaintImages(databaseRef, cid, Image1, Image2);

      return true;
    } catch (e) {
      print('submitLostAndFound failed: $e');
      return false;
    }
  }

  Future<void> _uploadComplaintImages(
    DatabaseReference databaseRef,
    int cid,
    File image1,
    File image2,
  ) async {
    try {
      final results = await Future.wait([
        StorageService.uploadFile(
          storagePath: "complaints/${cid}_1",
          file: image1,
        ),
        StorageService.uploadFile(
          storagePath: "complaints/${cid}_2",
          file: image2,
        ),
      ]);

      final imageUpdates = <String, dynamic>{};
      if (results[0] != null) imageUpdates['Image1'] = results[0];
      if (results[1] != null) imageUpdates['Image2'] = results[1];
      if (imageUpdates.isEmpty) return;

      await databaseRef
          .child("/Complaints/All/$cid")
          .update(imageUpdates)
          .timeout(FirebaseService.rtdbTimeout);
    } catch (e) {
      print('Complaint image upload failed: $e');
    }
  }
}
