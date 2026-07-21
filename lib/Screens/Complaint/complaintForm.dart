import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:safe_me/service/firebase_service.dart';
import 'package:safe_me/service/storage_service.dart';
import 'package:safe_me/service/userService.dart';
import 'package:safe_me/util/user_data_util.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:motion_toast/resources/arrays.dart';
import 'package:video_player/video_player.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../../data/sri_lanka_locations.dart';
import '../../Controller/language_controller.dart';
import '../../Resources/colors.dart';
import '../../Resources/style.dart';
import '../../widgets/drawer.dart';
import '../../widgets/legal_acceptance_title.dart';
import '../../widgets/safe_date_field.dart';
import '../../widgets/forgotPasswordAlertContent.dart';
import '../../widgets/visible_dialogbutton.dart';
import '../home_base.dart';
import 'complaint_base.dart';
import 'complaint_ui.dart';
import 'package:file_picker/file_picker.dart';

class ComplaintForm extends StatefulWidget {
  // ComplaintForm(this.complaintCategory);

  // final String complaintCategory;

  @override
  _ComplaintFormState createState() => _ComplaintFormState();
}

class _ComplaintFormState extends State<ComplaintForm> {
  bool isVideo = false;
  File? _file1;
  File? _file2;
  bool LostAndFound = false;
  bool isAgree = false;
  late VideoPlayerController _videoPlayerController;

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

  Future<void> _initScreen() async {
    await getUserData();
    await getCurrLocation();
  }

  final _txtDescriptionController = TextEditingController();

  getUserData() async {
    final nic = await UserService().requireLoggedInNic();
    if (nic == null) return;
    EasyLoading.show(status: "Getting User Data");
    try {
      final databaseRef = FirebaseService.instance.rootRef;

      var get_UserData = databaseRef.child('/PublicUsers/All/').child(nic);
      DatabaseEvent event = await get_UserData.once();

      if (event.snapshot.value == null) {
        return;
      }

      Map<String, dynamic> data = UserDataUtil.withDefaults(
        jsonDecode(jsonEncode(event.snapshot.value)) as Map<String, dynamic>,
        nic,
      );
      if (!mounted) return;
      setState(() {
        userData = data;
      });

      print("************ User Data = ${data}**************");
      print("************  User Email = ${data['Email']}**************");
    } catch (e) {
      debugPrint('Failed to load user data: $e');
    } finally {
      EasyLoading.dismiss();
    }
  }

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
      backgroundColor: appSurface,
      appBar: ComplaintUi.appBar(
        context: context,
        title: 'PlaceComplaint'.tr(),
        sysWidth: sysWidth,
        onBack: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ComplaintHome()),
          );
        },
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
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: ListView(
                children: [
                  const SizedBox(height: 8),
                  FormBuilderDropdown(
                    onChanged: (val) => setState(() {
                      selectDistrict = val.toString();
                    }),
                    name: 'district',
                    decoration: ComplaintUi.fieldDecoration('district'.tr()),
                    // initialValue: allGroups[0],
                    validator: (value) =>
                        value == null ? "Enter Your District" : null,

                    items: SriLankaLocations.dropdownItems(
                      SriLankaLocations.districts,
                    ),
                  ),
                  const SizedBox(height: 14),
                  FormBuilderDropdown(
                    onChanged: (val) => setState(() {
                      selectCity = val.toString();
                    }),
                    name: 'city',
                    decoration: ComplaintUi.fieldDecoration('City'.tr()),
                    validator: (value) =>
                        value == null ? "Enter Your City" : null,
                    // initialValue: allGroups[0],

                    items: SriLankaLocations.dropdownItems(
                      SriLankaLocations.cities,
                    ),
                  ),
                  const SizedBox(height: 14),
                  SafeDateField(
                    name: 'dateTime',
                    labelText: "DateTime".tr(),
                    labelStyle: hintTextStyle,
                    focusColor: secondary,
                    initialValue: DateTime.now(),
                    lastDate: DateTime.now(),
                    firstDate: DateTime.now().subtract(const Duration(days: 5)),
                    onChanged: (val) => setState(() {
                      if (val != null) selectDate = val;
                    }),
                    validator: (value) =>
                        value == null ? "Select incident date" : null,
                  ),
                  const SizedBox(height: 14),
                  FormBuilderDropdown(
                    onChanged: (val) => setState(() {
                      selectType = val.toString();
                    }),
                    name: 'type',
                    decoration:
                        ComplaintUi.fieldDecoration('ComplaintType'.tr()),
                    validator: (value) =>
                        value == null ? "Select Your Complaint Type" : null,
                    // initialValue: allGroups[0],

                    items:
                        ComplaintType.map((ComplaintType) => DropdownMenuItem(
                              alignment: AlignmentDirectional.centerStart,
                              value: ComplaintType,
                              child: Text(ComplaintType),
                            )).toList(),
                  ),
                  const SizedBox(height: 14),
                  FormBuilderTextField(
                    cursorColor: secondary,
                    minLines: 5,
                    maxLines: 15,
                    name: 'description',
                    controller: _txtDescriptionController,
                    decoration:
                        ComplaintUi.fieldDecoration('Description'.tr()),
                    validator: (value) =>
                        value!.isEmpty ? 'Description is Required' : null,
                  ),
                  const SizedBox(height: 22),
                  Text(
                    'SelectImages'.tr(),
                    style: TextStyle(
                      fontSize: 14,
                      color: secondary,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins-Bold',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ComplaintUi.imagePickerBox(
                        size: sysWidth / 3.2,
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: appSurfaceElevated,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(20),
                              ),
                            ),
                            builder: ((build) => bottomSheet()),
                          );
                        },
                        child: _file1 == null
                            ? Image.asset(
                                'assets/images/no_media.png',
                                fit: BoxFit.cover,
                              )
                            : Image.file(_file1!, fit: BoxFit.cover),
                      ),
                      ComplaintUi.imagePickerBox(
                        size: sysWidth / 3.2,
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: appSurfaceElevated,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(20),
                              ),
                            ),
                            builder: ((build) => bottomSheet()),
                          );
                        },
                        child: _file2 == null
                            ? Image.asset(
                                'assets/images/no_media.png',
                                fit: BoxFit.cover,
                              )
                            : Image.file(_file2!, fit: BoxFit.cover),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  FormBuilderCheckbox(
                    onChanged: (val) => setState(() {
                      isAgree = true;
                    }),
                    name: 'accept_terms',
                    initialValue: false,
                    activeColor: secondary,
                    // onChanged: _onChanged,
                    title: const LegalAcceptanceTitle(),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ComplaintUi.primaryButton(
                        label: 'Submit'.tr(),
                        icon: Icons.upload_file_outlined,
                        width: sysWidth * 0.72,
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
                                  final type =
                                      formData['type'] as String? ?? '';
                                  final date = formData['dateTime'] as DateTime? ??
                                      selectDate;
                                  final description =
                                      formData['description'] as String? ??
                                          _txtDescriptionController.text;

                                  EasyLoading.show(status: "Submitting...");
                                  print("******Validate******");
                                  var result = false;
                                  Object? submitError;
                                  try {
                                    result = await submitComplaint(
                                        UserDataUtil.field(userData, 'Address'),
                                        city,
                                        date,
                                        description,
                                        district,
                                        UserDataUtil.field(userData, 'Email'),
                                        _file1 as File,
                                        _file2 as File,
                                        _position.latitude,
                                        _position.longitude,
                                        UserDataUtil.mobileAsInt(userData),
                                        UserDataUtil.field(userData, 'NIC'),
                                        UserDataUtil.field(userData, 'Name'),
                                        UserDataUtil.field(
                                            userData, 'ProfileImage'),
                                        type);
                                  } catch (e) {
                                    submitError = e;
                                  } finally {
                                    EasyLoading.dismiss();
                                  }

                                  if (result == true) {
                                    EasyLoading.showSuccess(
                                        'Submitted successfully!');

                                    Future.delayed(Duration(seconds: 3),
                                        () async {
                                      EasyLoading.dismiss();
                                      print(
                                          "******Complaint Submitted successfully!******");
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
                                      submitError is TimeoutException
                                          ? 'Submission timed out. Check internet and try again.'
                                          : 'Complaint Submitted Failed',
                                    );
                                  }
                                } else {
                                  EasyLoading.dismiss();
                                  MotionToast.error(
                                    title: Text("Error"),
                                    description: Text(
                                        "Please Agree to Terms & Condition"),
                                    animationType: AnimationType.slideInFromLeft,
                                    toastAlignment: Alignment.topCenter,
                                  ).show(context);
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
                            } finally {}
                          },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
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
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 4,
            decoration: BoxDecoration(
              color: appBorder,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'ChooseFrom'.tr(),
            style: TextStyle(
              fontSize: 16,
              color: secondary,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins-Bold',
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _sourceOption(
                icon: Icons.camera_alt_outlined,
                label: 'Camera'.tr(),
                onTap: () {
                  Navigator.pop(context);
                  takePhoto(ImageSource.camera);
                },
              ),
              _sourceOption(
                icon: Icons.image_outlined,
                label: 'Gallery'.tr(),
                onTap: () {
                  Navigator.pop(context);
                  pickPhoto(ImageSource.gallery);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          width: 120,
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: appSurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: appBorder),
          ),
          child: Column(
            children: [
              Icon(icon, color: secondary, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: secondary,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins-Bold',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> submitComplaint(
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
    String Type,
  ) async {
    final firebase = FirebaseService.instance;
    final nicKey = UserDataUtil.normalizeNic(NIC);

    try {
      await firebase.ensureAuthenticatedForWrite();
      print('submitComplaint: auth OK');

      final cid = await firebase.allocateNextComplaintId();
      print('submitComplaint: CID=$cid');

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
        "NIC": nicKey,
        "Name": Name,
        "ProfileImage": ProfileImage,
        "Reason": "",
        "Status": "Pending",
        "Type": Type,
      };

      await firebase.saveComplaintToAll(cid: cid, data: data);
      print('submitComplaint: saved Complaints/All/$cid');

      await firebase.syncLegacyComplaintCounters(cid);

      _uploadComplaintImages(firebase, nicKey, cid, Image1, Image2);

      return true;
    } catch (e, st) {
      print('submitComplaint failed: $e');
      print(st);
      return false;
    }
  }

  Future<void> _uploadComplaintImages(
    FirebaseService firebase,
    String nicKey,
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

      await firebase.patchComplaintInAll(cid: cid, updates: imageUpdates);
    } catch (e) {
      print('Complaint image upload failed: $e');
    }
  }
}
