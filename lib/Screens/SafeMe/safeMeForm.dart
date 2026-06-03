import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:safe_me/service/firebase_service.dart';
import 'package:safe_me/service/userService.dart';
import 'package:image_picker/image_picker.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:motion_toast/resources/arrays.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:safe_me/Screens/SafeMe/safeMeBase.dart';
import 'package:video_player/video_player.dart';

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

  var districts = ['Ampara','Anuradhapura','Badulla','Batticaloa', 'Colombo','Galle',
    'Gampaha','Hambantota','Jaffna', 'Kalutara','Kandy', 'Kegalle', 'Hambantota', 'Kegalle' ];

  var city = ['Gampaha','Veyangoda','Minuwangoda', 'Nittabuwa', 'Aththnagalla','Kaduwela','Kolonnawa', 'Maharagama','Kesbewa','Nugegoda','Ahangama', 'Ambalangoda' ,'Balapitiya' ];

  var ComplaintType = [
    'Minor Complaints',
    'Minor Crime (Less than Rs.50,000)',
    'Crime',
    'Murder',
    'Traffic Viloation',
    'Crime against women & children'
  ];

  late String selectDistrict;
  late String selectCity;
  late String selectType;
  late DateTime selectDate;

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
    String aa = (event.snapshot.value).toString();
    Map<String, dynamic> data =
        jsonDecode(jsonEncode(event.snapshot.value)) as Map<String, dynamic>;
    setState(() {
      userData = data;
    });

    print("************ User Data = ${data}**************");
    print("************  User Email = ${data['Email']}**************");
    EasyLoading.dismiss();
  }

  Future initRecorder() async {
    final status = await Permission.microphone.request();

    if (status != PermissionStatus.granted) {
      throw 'Microphone permission not granted';
    }
    // await recorder.openRecorder();
    isRecorderReady = true;

    recorder.setSubscriptionDuration(
      const Duration(milliseconds: 500),
    );
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
    // recorder.closeRecorder();
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
                            EasyLoading.show(status: "Submitting...");
                            try {
                              if (_fbKey.currentState!.validate() &&
                                  _file1 != null &&
                                  _file2 != null) {
                                print("******Validate******");
                                var result = await submitSafeMe(
                                    userData['Address'],
                                    "",
                                    //AudioMP3
                                    selectCity,
                                    DateTime.now(),
                                    selectDistrict,
                                    userData['Email'],
                                    _file1 as File,
                                    _file2 as File,
                                    _file3 as File,
                                    _file4 as File,
                                    _file5 as File,
                                    _position.latitude,
                                    _position.longitude,
                                    int.parse(userData['Mobile']),
                                    userData['NIC'],
                                    userData['Name'],
                                    userData['ProfileImage']);

                                if (result = true) {
                                  EasyLoading.dismiss();
                                  EasyLoading.showSuccess(
                                      'SafeMe Submitted successfully!');

                                  Future.delayed(Duration(milliseconds: 3500),
                                      () async {
                                    print(
                                        "******SafeMe Submitted successfully!******");
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

                              print("******Not Validate******");
                            } finally {}
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

  Future<bool?> submitSafeMe(
    String Address,
    String AudioMP3,
    String City,
    DateTime Date,
    String District,
    String Email,
    File Image1,
    File Image2,
    File Image3,
    File Image4,
    File Image5,
    double Latitude,
    double Longitude,
    int Mobile,
    String NIC,
    String Name,
    String ProfileImage,
  ) async {
    final databaseRef = FirebaseService.instance.rootRef;
    FirebaseStorage storage = FirebaseStorage.instance;
    EasyLoading.show(status: "Submitting...");

    ///Get Last safeme ID -1st Step

    var get_SID = databaseRef.child("/SafeMe/LastSID");
    DatabaseEvent event = await get_SID.once();
    int SID = (event.snapshot.value).hashCode + 1;
    print("************ Complaint ID = $SID**************");

    if (SID != null) {
      try {
        print("************Get Complaint ID = $SID");
        var data = {
          "SID": SID,
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
          "Latitude": Longitude,
          "Longitude": Latitude,
          "Mobile": Mobile,
          "NIC": NIC,
          "Name": Name,
          "ProfileImage": ProfileImage,
          "Severity": "Medium",
          "Status": "Alert Sent"
        };

        ///Save SafeMe - 2nd Step

        databaseRef.child("/SafeMe/All/").child("$SID").set(data);
        print("**************Save SafeMe response ");

        /// update SafeMe image Url

        Reference ref_Im1 =
            storage.ref().child("/safeme images/" + "$SID" "_1");
        await ref_Im1.putFile(Image1);
        Reference ref_Im2 =
            storage.ref().child("/safeme images/" + "$SID" "_2");
        await ref_Im2.putFile(Image2);
        Reference ref_Im3 =
            storage.ref().child("/safeme images/" + "$SID" "_3");
        await ref_Im3.putFile(Image3);
        Reference ref_Im4 =
            storage.ref().child("/safeme images/" + "$SID" "_4");
        await ref_Im4.putFile(Image4);
        Reference ref_Im5 =
            storage.ref().child("/safeme images/" + "$SID" "_5");
        await ref_Im5.putFile(Image5);

        String image1Url = await ref_Im1.getDownloadURL();
        String image2Url = await ref_Im2.getDownloadURL();
        String image3Url = await ref_Im3.getDownloadURL();
        String image4Url = await ref_Im4.getDownloadURL();
        String image5Url = await ref_Im5.getDownloadURL();
        print("********Image_1 URL = $image1Url");
        print("********Image_2 URL = $image2Url");

        databaseRef.child("/SafeMe/All/$SID").update({
          'Image1': image1Url,
          'Image2': image2Url,
          'Image3': image3Url,
          'Image4': image4Url,
          'Image5': image5Url
        });

        ///Update Last SafeMe ID
        databaseRef.child("/SafeMe/").update({'LastSID': SID});

        ///Update SafeMe Count
        var getSafeMeCount = databaseRef.child("/SafeMe/PendingCount");
        DatabaseEvent event = await getSafeMeCount.once();
        print(event.snapshot.value);
        int SafeMe_PCount = (event.snapshot.value).hashCode + 1;
        databaseRef.child("/SafeMe/").update({'PendingCount': SafeMe_PCount});

        ///Update SafeMe Total Count
        var getSafeMeTotalCount = databaseRef.child("/SafeMe/TotalCount");
        DatabaseEvent eventT = await getSafeMeTotalCount.once();
        print(eventT.snapshot.value);
        int SafeMe_ToCount = (eventT.snapshot.value).hashCode + 1;
        databaseRef.child("/SafeMe/").update({'TotalCount': SafeMe_ToCount});

        return true;
      } catch (e) {
        print(e);
        return false;
      }
    }
  }
}
