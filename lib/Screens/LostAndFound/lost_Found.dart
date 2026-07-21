import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:safe_me/service/firebase_service.dart';
import 'package:safe_me/service/storage_service.dart';
import 'package:safe_me/service/userService.dart';
import 'package:safe_me/util/user_data_util.dart';
import 'package:image_picker/image_picker.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:motion_toast/resources/arrays.dart';
import 'package:provider/provider.dart';

import '../../data/sri_lanka_locations.dart';
import '../../Controller/language_controller.dart';
import '../../Resources/colors.dart';
import '../../Resources/style.dart';
import '../../widgets/drawer.dart';
import '../../widgets/legal_acceptance_title.dart';
import '../../widgets/safe_date_field.dart';
import '../Complaint/complaint_ui.dart';
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
    double sysWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: appSurface,
      appBar: ComplaintUi.appBar(
        context: context,
        title: 'Lost_Found'.tr(),
        sysWidth: sysWidth,
        onBack: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeBase()),
          );
        },
      ),
      drawer: Drawer(
        child: DrawerWidget(),
      ),
      body: FormBuilder(
        key: _fbKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            ComplaintUi.sectionCard(
              title: 'Location_Details'.tr(),
              child: Column(
                children: [
                  FormBuilderDropdown(
                    onChanged: (val) => setState(() {
                      selectDistrict = val.toString();
                    }),
                    name: 'district',
                    decoration: ComplaintUi.fieldDecoration('district'.tr()),
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
                    items: SriLankaLocations.dropdownItems(
                      SriLankaLocations.cities,
                    ),
                  ),
                  const SizedBox(height: 14),
                  SafeDateField(
                    name: 'dateTime',
                    labelText: 'DateTime'.tr(),
                    labelStyle: TextStyle(
                      color: appTextMuted,
                      fontFamily: 'Poppins-Light',
                    ),
                    focusColor: secondary,
                    includeTime: true,
                    lastDate: DateTime.now(),
                    firstDate:
                        DateTime.now().subtract(const Duration(days: 5)),
                    onChanged: (val) => setState(() {
                      if (val != null) selectDate = val;
                    }),
                    validator: (value) => value == null
                        ? "Enter Lost or Found Date & Time"
                        : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ComplaintUi.sectionCard(
              title: 'Lost_Found_Details'.tr(),
              child: FormBuilderTextField(
                cursorColor: secondary,
                minLines: 5,
                maxLines: 12,
                name: 'description',
                controller: _txtDescriptionController,
                decoration: ComplaintUi.fieldDecoration('Description'.tr()),
                validator: (value) =>
                    value!.isEmpty ? 'Description is Required' : null,
              ),
            ),
            const SizedBox(height: 16),
            ComplaintUi.sectionCard(
              title: 'SelectImages'.tr(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _imageSlot(sysWidth, _file1),
                  _imageSlot(sysWidth, _file2),
                ],
              ),
            ),
            const SizedBox(height: 16),
            FormBuilderCheckbox(
              onChanged: (val) => setState(() {
                isAgree = true;
              }),
              name: 'accept_terms',
              initialValue: false,
              activeColor: secondary,
              title: const LegalAcceptanceTitle(),
            ),
            const SizedBox(height: 20),
            ComplaintUi.primaryButton(
              label: 'Submit'.tr(),
              icon: Icons.upload_file_outlined,
              width: double.infinity,
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
                      final city = formData['city'] as String? ?? '';
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
                          UserDataUtil.field(userData, 'ProfileImage'),
                        );
                      } finally {
                        EasyLoading.dismiss();
                      }

                      if (result) {
                        EasyLoading.showSuccess(
                          'Lost and Found Complaint Submitted successfully!',
                          duration: Duration(seconds: 5),
                        );
                        print(
                            "******Complaint Submitted successfully!******");
                        if (!context.mounted) return;
                        Navigator.pop(context);
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => HomeBase()),
                          (route) => false,
                        );
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
                      description: Text("Please Select Evidence Images"),
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageSlot(double sysWidth, File? file) {
    return ComplaintUi.imagePickerBox(
      size: sysWidth / 2.4,
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: appSurfaceElevated,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: ((build) => bottomSheet()),
        );
      },
      child: file == null
          ? Image.asset('assets/images/no_media.png', fit: BoxFit.cover)
          : Image.file(file, fit: BoxFit.cover),
    );
  }

  Widget bottomSheet() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: appBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'ChooseFrom'.tr(),
            style: TextStyle(
              fontSize: 18,
              color: secondary,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins-Bold',
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _bottomSheetOption(
                icon: Icons.camera_alt_outlined,
                label: 'Camera'.tr(),
                onTap: () {
                  Navigator.pop(context);
                  takePhoto(ImageSource.camera);
                },
              ),
              _bottomSheetOption(
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

  Widget _bottomSheetOption({
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
          width: 110,
          height: 100,
          decoration: BoxDecoration(
            color: appSurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: appBorder),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
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
