import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:safe_me/service/firebase_service.dart';
import 'package:safe_me/service/storage_service.dart';
import 'package:safe_me/service/userService.dart';
import 'package:safe_me/util/user_data_util.dart';
import 'package:image_picker/image_picker.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:motion_toast/resources/arrays.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:safe_me/Screens/SafeMe/safeMeBase.dart';
import 'package:video_player/video_player.dart';

import '../../data/sri_lanka_locations.dart';
import '../../Controller/language_controller.dart';
import '../../Resources/colors.dart';
import '../../Resources/style.dart';
import '../../widgets/drawer.dart';
import '../home_base.dart';

class SafeMeForm extends StatefulWidget {
  const SafeMeForm({Key? key}) : super(key: key);

  @override
  State<SafeMeForm> createState() => _SafeMeFormState();
}

class _SafeMeFormState extends State<SafeMeForm> {
  bool isVideo = false;
  File? _file1, _file2, _file3, _file4, _file5;
  bool LostAndFound = false;
  bool isAgree = false;
  FlutterSoundRecorder recorder = FlutterSoundRecorder();
  bool isRecorderReady = false;

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
      if (img == null) return;
      _file1 == null
          ? _file1 = File(img.path)
          : _file2 == null
              ? _file2 = File(img.path)
              : _file3 == null
                  ? _file3 = File(img.path)
                  : _file4 == null
                      ? _file4 = File(img.path)
                      : _file5 = File(img.path);
    });
  }

  pickPhoto(ImageSource source) async {
    final img = await FilePicker.platform.pickFiles(type: FileType.image);
    PlatformFile file = img!.files.first;
    // _file = File(file.path!);
    setState(() {
      // _file1 == null ? _file1 = File(file.path!) : _file2 = File(file.path!);
      _file1 == null
          ? _file1 = File(file.path!)
          : _file2 == null
              ? _file2 = File(file.path!)
              : _file3 == null
                  ? _file3 = File(file.path!)
                  : _file4 == null
                      ? _file4 = File(file.path!)
                      : _file5 = File(file.path!);
    });
  }

  Future record() async {
    if (!isRecorderReady) return;
    await recorder.startRecorder(toFile: 'audio');
  }

  Future stop() async {
    if (!isRecorderReady) return;

    final recodePath = await recorder.stopRecorder();
    final audioFile = File(recodePath!);

    print('*************Audio File Path = $audioFile');
  }

  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  final GlobalKey<FormBuilderState> _fbKeyValidation =
      GlobalKey<FormBuilderState>();
  TextEditingController _txtLocation = TextEditingController();

  var ComplaintType = [
    'Minor Complaints',
    'Minor Crime (Less than Rs.50,000)',
    'Crime',
    'Murder',
    'Traffic Viloation',
    'Crime against women & children'
  ];

  String selectDistrict = '';
  String selectCity = '';
  String selectType = '';
  DateTime selectDate = DateTime.now();

  getCurrLocation() async {
    EasyLoading.show(status: "Getting Your Location");
    Position positionCur = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    print("///////////////////////$positionCur//////////////////////////");
    EasyLoading.dismiss();
    setState(() {
      _position = positionCur;
      _txtLocation.text =
          "${positionCur.latitude.toStringAsFixed(7)} , ${positionCur.longitude.toStringAsFixed(7)}";
    });
  }

  final _txtDescriptionController = TextEditingController();

  getUserData() async {
    final nic = await UserService().requireLoggedInNic();
    if (nic == null) return;
    EasyLoading.show(status: "Getting User Data");
    final databaseRef = FirebaseService.instance.rootRef;

    var get_UserData = databaseRef.child('/PublicUsers/All/').child(nic);
    DatabaseEvent event = await get_UserData.once();

    if (event.snapshot.value == null) {
      EasyLoading.dismiss();
      return;
    }

    Map<String, dynamic> data = UserDataUtil.withDefaults(
      jsonDecode(jsonEncode(event.snapshot.value)) as Map<String, dynamic>,
      nic,
    );
    setState(() {
      userData = data;
    });

    print("************ User Data = ${data}**************");
    print("************  User Email = ${data['Email']}**************");
    EasyLoading.dismiss();
  }

  Future initRecorder() async {
    try {
      final status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) return;

      await recorder.openRecorder();
      isRecorderReady = true;
      recorder.setSubscriptionDuration(
        const Duration(milliseconds: 500),
      );
    } catch (e) {
      debugPrint('Recorder init failed: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    getUserData();
    getCurrLocation();
    initRecorder();
  }

  @override
  void dispose() {
    if (isRecorderReady) {
      recorder.closeRecorder();
    }
    super.dispose();
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
          "Place a Emergency",
          style: TextStyle(
              fontSize: 15,
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
                  MaterialPageRoute(builder: (context) => const SafeMeBase()));
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

                    items: SriLankaLocations.dropdownItems(
                      SriLankaLocations.districts,
                    ),
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

                    items: SriLankaLocations.dropdownItems(
                      SriLankaLocations.cities,
                    ),
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
                          child: _file3 == null
                              ? Image.asset(
                                  "assets/images/no_media.png",
                                  height: sysWidth / 4,
                                  width: sysWidth / 4,
                                  fit: BoxFit.cover,
                                )
                              : Image.file(_file3!,
                                  fit: BoxFit.fill, height: 20),
                        ),
                      ),
                    ],
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
                          child: _file4 == null
                              ? Image.asset(
                                  "assets/images/no_media.png",
                                  height: sysWidth / 4,
                                  width: sysWidth / 4,
                                  fit: BoxFit.cover,
                                )
                              : Image.file(_file4!,
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
                          child: _file5 == null
                              ? Image.asset(
                                  "assets/images/no_media.png",
                                  height: sysWidth / 4,
                                  width: sysWidth / 4,
                                  fit: BoxFit.cover,
                                )
                              : Image.file(_file5!,
                                  fit: BoxFit.fill, height: 20),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Recode Audio",
                    style: TextStyle(
                        // fontSize: 20,
                        color: tilsTextColor,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins-Light'),
                  ),
                  SizedBox(height: 20),
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          if (recorder.isRecording) {
                            await stop();
                          } else {
                            await record();
                          }
                        },
                        child: Icon(
                          recorder.isRecording ? Icons.stop : Icons.mic,
                        ),
                      ),
                      SizedBox(width: 10),
                      StreamBuilder<RecordingDisposition>(
                        stream: recorder.onProgress,
                        builder: (context, snapshot) {
                          final duration = snapshot.hasData
                              ? snapshot.data!.duration
                              : Duration.zero;
                          return Text("${duration.inSeconds} s");
                        },
                      ),
                    ],
                  ),
                  SizedBox(width: 10),
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
                                final district =
                                    formData['district'] as String? ?? '';
                                final city =
                                    formData['city'] as String? ?? '';

                                EasyLoading.show(status: "Submitting...");
                                print("******Validate******");
                                var result = false;
                                try {
                                  result = await submitSafeMe(
                                      UserDataUtil.field(userData, 'Address'),
                                      "",
                                      city,
                                      DateTime.now(),
                                      district,
                                      UserDataUtil.field(userData, 'Email'),
                                      _file1!,
                                      _file2!,
                                      _file3,
                                      _file4,
                                      _file5,
                                      _position.latitude,
                                      _position.longitude,
                                      UserDataUtil.mobileAsInt(userData),
                                      UserDataUtil.field(userData, 'NIC'),
                                      UserDataUtil.field(userData, 'Name'),
                                      UserDataUtil.field(
                                          userData, 'ProfileImage'));
                                } finally {
                                  EasyLoading.dismiss();
                                }

                                if (result == true) {
                                  EasyLoading.showSuccess(
                                      'SafeMe Submitted successfully!');

                                  Future.delayed(Duration(milliseconds: 3500),
                                      () async {
                                    EasyLoading.dismiss();
                                    print(
                                        "******SafeMe Submitted successfully!******");
                                    if (!context.mounted) return;
                                    Navigator.pop(context);
                                    Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => HomeBase()),
                                        (route) => false);
                                  });
                                } else {
                                  EasyLoading.showError(
                                      "SafeMe Submitted Failed");
                                }
                              } else {
                                EasyLoading.dismiss();
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

  Future<bool> submitSafeMe(
    String Address,
    String AudioMP3,
    String City,
    DateTime Date,
    String District,
    String Email,
    File Image1,
    File Image2,
    File? Image3,
    File? Image4,
    File? Image5,
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

      final sidEvent = await databaseRef
          .child("/SafeMe/LastSID")
          .once()
          .timeout(timeout);
      var sid = int.tryParse('${sidEvent.snapshot.value}') ?? 0;
      sid++;

      print("************ SafeMe ID = $sid**************");

      final data = {
        "SID": sid,
        "Address": Address,
        "AudioMP3": "",
        "City": City,
        "Date": Date.toString(),
        "District": District,
        "Email": Email,
        "Image1": "",
        "Image2": "",
        "Image3": "",
        "Image4": "",
        "Image5": "",
        "Latitude": Latitude,
        "Longitude": Longitude,
        "Mobile": Mobile,
        "NIC": NIC,
        "Name": Name,
        "ProfileImage": ProfileImage,
        "Severity": "Medium",
        "Status": "Alert Sent",
      };

      await databaseRef
          .child("/SafeMe/All/$sid")
          .set(data)
          .timeout(timeout);
      print("**************Save SafeMe response ");

      await databaseRef
          .child("/SafeMe/LastSID")
          .set(sid)
          .timeout(timeout);

      final pendingEvent = await databaseRef
          .child("/SafeMe/PendingCount")
          .once()
          .timeout(timeout);
      final pending = int.tryParse('${pendingEvent.snapshot.value}') ?? 0;
      await databaseRef
          .child("/SafeMe/PendingCount")
          .set(pending + 1)
          .timeout(timeout);

      final totalEvent = await databaseRef
          .child("/SafeMe/TotalCount")
          .once()
          .timeout(timeout);
      final total = int.tryParse('${totalEvent.snapshot.value}') ?? 0;
      await databaseRef
          .child("/SafeMe/TotalCount")
          .set(total + 1)
          .timeout(timeout);

      _uploadSafeMeImages(
        databaseRef,
        sid,
        Image1,
        Image2,
        Image3,
        Image4,
        Image5,
      );

      return true;
    } catch (e) {
      print('submitSafeMe failed: $e');
      return false;
    }
  }

  Future<void> _uploadSafeMeImages(
    DatabaseReference databaseRef,
    int sid,
    File image1,
    File image2,
    File? image3,
    File? image4,
    File? image5,
  ) async {
    try {
      final files = [image1, image2, image3, image4, image5];
      final imageUpdates = <String, dynamic>{};

      await Future.wait(List.generate(files.length, (index) async {
        final file = files[index];
        if (file == null) return;
        final url = await StorageService.uploadFile(
          storagePath: "safeme images/${sid}_${index + 1}",
          file: file,
        );
        if (url != null) imageUpdates['Image${index + 1}'] = url;
      }));

      if (imageUpdates.isEmpty) return;

      await databaseRef
          .child("/SafeMe/All/$sid")
          .update(imageUpdates)
          .timeout(FirebaseService.rtdbTimeout);
    } catch (e) {
      print('SafeMe image upload failed: $e');
    }
  }
}
