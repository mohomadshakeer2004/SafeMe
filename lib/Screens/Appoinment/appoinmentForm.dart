import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_svg/svg.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:motion_toast/resources/arrays.dart';
import 'package:provider/provider.dart';
// import 'package:safe_me/Screens/Schedule/appointment_base.dart';

import '../../data/sri_lanka_locations.dart';
import '../../Controller/language_controller.dart';
import '../../Resources/colors.dart';
import '../../Resources/style.dart';
import '../../widgets/drawer.dart';
import '../../widgets/legal_acceptance_title.dart';
import '../../widgets/safe_date_field.dart';
import '../../service/firebase_service.dart';
import '../../service/userService.dart';
import '../../util/user_data_util.dart';
import 'appointment_base.dart';

class AppointmentForm extends StatefulWidget {
  const AppointmentForm({Key? key}) : super(key: key);

  @override
  _AppointmentFormState createState() => _AppointmentFormState();
}

class _AppointmentFormState extends State<AppointmentForm> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  final GlobalKey<FormBuilderState> _fbKeyValidation =
      GlobalKey<FormBuilderState>();

  late String selectDistrict;
  late String selectCity;
  late String selectType;
  late DateTime selectDate;
  bool isAgree = false;

  final _txtDescriptionController = TextEditingController();
  Map<String, dynamic> userData = {};

  var AppointmentType = [
    'Minor Complaints',
    'Minor Crime (Less than Rs.50,000)',
    'Crime',
    'Murder',
    'Traffic Viloation',
    'Crime against women & children',
    'Other'
  ];

  Future<void> getUserData() async {
    final nic = await UserService().requireLoggedInNic();
    if (nic == null) return;
    try {
      final snapshot = await FirebaseService.instance
          .rootRef
          .child('PublicUsers/All/$nic')
          .get()
          .timeout(FirebaseService.rtdbTimeout);
      if (snapshot.value == null) return;
      final data = UserDataUtil.withDefaults(
        jsonDecode(jsonEncode(snapshot.value)) as Map<String, dynamic>,
        nic,
      );
      if (!mounted) return;
      setState(() => userData = data);
    } catch (e) {
      debugPrint('Failed to load user data: $e');
    }
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
    return Scaffold(
      backgroundColor: mainBGColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: mainBGColor,
        // iconTheme: IconThemeData(color: iconColor),
        title: Text(
          "Place_Appointment".tr(),
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
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AppointmentBase()));
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
                  SizedBox(height: 15),
                  SafeDateField(
                    name: 'requestDateTime',
                    labelText: "RequestDateTime".tr(),
                    labelStyle: hintTextStyle,
                    focusColor: secondary,
                    includeTime: true,
                    firstDate: DateTime.now(),
                    onChanged: (val) => setState(() {
                      if (val != null) selectDate = val;
                    }),
                    validator: (value) =>
                        value == null ? "Enter Required Date & Time" : null,
                  ),
                  SizedBox(height: 15),
                  FormBuilderDropdown(
                    onChanged: (val) => setState(() {
                      selectType = val.toString();
                    }),
                    name: 'type',
                    validator: (value) =>
                        value == null ? "Select Your Appointment Type" : null,
                    decoration: InputDecoration(
                      labelText: "AppointmentType".tr(),
                      labelStyle: hintTextStyle,
                      contentPadding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: secondary)),
                    ),
                    // initialValue: allGroups[0],

                    items: AppointmentType.map(
                        (AppointmentType) => DropdownMenuItem(
                              alignment: AlignmentDirectional.centerStart,
                              value: AppointmentType,
                              child: Text(AppointmentType),
                            )).toList(),
                  ),
                  SizedBox(height: 15),
                  FormBuilderTextField(
                    cursorColor: secondary,
                    minLines: 5,
                    maxLines: 15,
                    name: 'description',
                    validator: (value) =>
                        value!.isEmpty ? 'Description is Required' : null,
                    controller: _txtDescriptionController,
                    decoration: InputDecoration(
                      labelText: "Description".tr(),
                      labelStyle: hintTextStyle,
                      contentPadding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: secondary)),
                    ),
                  ),
                  SizedBox(height: 25),
                  SizedBox(height: 20),
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
                  SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                          onTap: () async {
                            try {
                              if (_fbKey.currentState!.validate()) {
                                if (isAgree == true) {
                                  final nic =
                                      UserDataUtil.field(userData, 'NIC');
                                  if (nic.isEmpty) {
                                    MotionToast.error(
                                      title: const Text("Error"),
                                      description: const Text(
                                          "User profile not loaded. Please try again."),
                                      animationType:
                                          AnimationType.slideInFromLeft,
                                      toastAlignment: Alignment.topCenter,
                                    ).show(context);
                                    return;
                                  }
                                  EasyLoading.show(status: "Submitting...");
                                  print("******Validate******");

                                  final result = await submitAppointment(
                                    UserDataUtil.field(userData, 'Address'),
                                    selectCity,
                                    _txtDescriptionController.text,
                                    selectDistrict,
                                    UserDataUtil.field(userData, 'Email'),
                                    UserDataUtil.mobileAsInt(userData),
                                    nic,
                                    UserDataUtil.field(userData, 'Name'),
                                    UserDataUtil.field(
                                        userData, 'ProfileImage'),
                                    selectDate,
                                    selectType,
                                  );

                                  EasyLoading.dismiss();
                                  if (!mounted) return;

                                  if (result == true) {
                                    EasyLoading.showSuccess(
                                        'Appointment Submitted successfully!',
                                        duration:
                                            const Duration(seconds: 3));
                                    print(
                                        "******Appointment Submitted successfully!******");
                                    Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              const AppointmentBase()),
                                      (route) => false,
                                    );
                                  } else {
                                    EasyLoading.showError(
                                        "Appointment Submitted Failed");
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
                              }
                            } catch (e) {
                              print(e);
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

  Future<bool> submitAppointment(
    String Address,
    String City,
    String Description,
    String District,
    String Email,
    int Mobile,
    String NIC,
    String Name,
    String ProfileImage,
    DateTime Date,
    String Type,
  ) async {
    final firebase = FirebaseService.instance;
    final timeout = FirebaseService.rtdbTimeout;
    final nicKey = UserDataUtil.normalizeNic(NIC);

    try {
      await firebase.ensureAuthenticatedForWrite();
      final databaseRef = firebase.rootRef;

      final aid = await firebase.nextAppointmentId();
      print("************ Appointment ID = $aid **************");

      final data = {
        "AID": aid,
        "Address": Address,
        "City": City,
        "Description": Description,
        "District": District,
        "Email": Email,
        "Mobile": Mobile,
        "NIC": nicKey,
        "Name": Name,
        "ProfileImage": ProfileImage,
        "RequestedDate": Date.toString(),
        "ScheduledDate": "Pending",
        "Type": Type,
      };

      // Use non-array path: /Records/$aid (avoids Firebase [null, record] sparse arrays).
      await databaseRef
          .child('/Appointments/PublicAppointments/Records/$aid')
          .set(data)
          .timeout(timeout);
      print("**************Save Appointment ");

      final countEvent = await databaseRef
          .child('/Appointments/PublicAppointmentCount')
          .once()
          .timeout(timeout);
      var count = int.tryParse('${countEvent.snapshot.value}') ?? 0;
      count++;
      await databaseRef
          .child('/Appointments')
          .update({
            'PublicAppointmentCount': count,
            'LastAID': aid,
          })
          .timeout(timeout);

      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }
}
