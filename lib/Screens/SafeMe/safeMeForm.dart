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
import 'package:path_provider/path_provider.dart';
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
  final FlutterSoundRecorder recorder = FlutterSoundRecorder();
  bool isRecorderReady = false;
  bool isRecording = false;
  File? _audioFile;
  String? _audioRecordPath;

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

  Future<void> record() async {
    if (!isRecorderReady || isRecording) return;
    try {
      final dir = await getTemporaryDirectory();
      _audioRecordPath =
          '${dir.path}/safeme_${DateTime.now().millisecondsSinceEpoch}.aac';
      await recorder.startRecorder(
        toFile: _audioRecordPath,
        codec: Codec.aacADTS,
      );
      if (!mounted) return;
      setState(() {
        isRecording = true;
        _audioFile = null;
      });
    } catch (e) {
      debugPrint('Start recording failed: $e');
    }
  }

  Future<void> stop() async {
    if (!isRecorderReady || !isRecording) return;
    try {
      final recordedPath = await recorder.stopRecorder();
      if (!mounted) return;
      setState(() => isRecording = false);

      final path = recordedPath ?? _audioRecordPath;
      if (path == null || path.isEmpty) return;

      final audioFile = File(path);
      if (!await audioFile.exists()) {
        debugPrint('Audio file missing at $path');
        return;
      }
      setState(() => _audioFile = audioFile);
      debugPrint('Audio saved: $path (${await audioFile.length()} bytes)');
    } catch (e) {
      debugPrint('Stop recording failed: $e');
      if (mounted) setState(() => isRecording = false);
    }
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

  Future<void> getCurrLocation() async {
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

  final _txtDescriptionController = TextEditingController();

  Future<void> getUserData() async {
    EasyLoading.show(status: "Getting User Data");
    try {
      final sessionOk = await UserService().checkSession();
      if (!sessionOk) return;

      final nic = await UserService().getLoggedInNic();
      if (nic == null || nic.isEmpty) return;

      final snapshot = await FirebaseService.instance.getPublicUser(nic);
      if (!snapshot.exists || snapshot.value == null) return;

      final data = UserDataUtil.withDefaults(
        jsonDecode(jsonEncode(snapshot.value)) as Map<String, dynamic>,
        nic,
      );
      if (!mounted) return;
      setState(() => userData = data);
    } catch (e) {
      debugPrint('Failed to load user data: $e');
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future initRecorder() async {
    try {
      final status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) return;

      await recorder.openRecorder();
      await recorder.setSubscriptionDuration(
        const Duration(milliseconds: 500),
      );
      if (!mounted) return;
      setState(() => isRecorderReady = true);
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
      if (isRecording) {
        recorder.stopRecorder();
      }
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
                          if (isRecording) {
                            await stop();
                          } else {
                            await record();
                          }
                        },
                        child: Icon(
                          isRecording ? Icons.stop : Icons.mic,
                        ),
                      ),
                      SizedBox(width: 10),
                      StreamBuilder<RecordingDisposition>(
                        stream: isRecorderReady ? recorder.onProgress : null,
                        builder: (context, snapshot) {
                          final duration = snapshot.hasData
                              ? snapshot.data!.duration
                              : Duration.zero;
                          return Text("${duration.inSeconds} s");
                        },
                      ),
                      if (_audioFile != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Audio ready',
                          style: TextStyle(
                            color: secondary,
                            fontFamily: 'Poppins-Light',
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(width: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                          onTap: () async {
                            try {
                              if (_fbKey.currentState!.saveAndValidate()) {
                                if (isRecording) {
                                  await stop();
                                }
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
                                      _file1,
                                      _file2,
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
                                  title: const Text("Error"),
                                  description: const Text(
                                      "Please complete all required fields"),
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
    File? Image1,
    File? Image2,
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
      final sid = await firebase.allocateNextSafeMeId();
      print('************ SafeMe ID = $sid **************');

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

      await firebase.saveSafeMeAlert(sid: sid, data: data);
      print('**************Save SafeMe response ');

      await firebase.syncSafeMeCounters(sid);

      _uploadSafeMeImages(
        firebase.rootRef,
        sid,
        Image1,
        Image2,
        Image3,
        Image4,
        Image5,
      );
      if (_audioFile != null) {
        _uploadSafeMeAudio(firebase.rootRef, sid, _audioFile!);
      }

      return true;
    } catch (e) {
      print('submitSafeMe failed: $e');
      return false;
    }
  }

  Future<void> _uploadSafeMeImages(
    DatabaseReference databaseRef,
    int sid,
    File? image1,
    File? image2,
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

  Future<void> _uploadSafeMeAudio(
    DatabaseReference databaseRef,
    int sid,
    File audioFile,
  ) async {
    try {
      final url = await StorageService.uploadFile(
        storagePath: 'safeme audio/$sid',
        file: audioFile,
      );
      if (url == null) return;

      await databaseRef
          .child('SafeMe/All/$sid')
          .update({'AudioMP3': url})
          .timeout(FirebaseService.rtdbTimeout);
    } catch (e) {
      debugPrint('SafeMe audio upload failed: $e');
    }
  }
}
