import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
import '../../widgets/safe_date_field.dart';
import '../home_base.dart';
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

  var AppointmentType = [
    'Minor Complaints',
    'Minor Crime (Less than Rs.50,000)',
    'Crime',
    'Murder',
    'Traffic Viloation',
    'Crime against women & children',
    'Other'
  ];

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
                              if (_fbKey.currentState!.validate()) {
                                if (isAgree == true) {
                                  EasyLoading.show(status: "Submitting...");
                                  print("******Validate******");

                                  var result = await submitAppointment(
                                      "100, Pattalagedra, Veyangoda",
                                      selectCity,
                                      _txtDescriptionController.text,
                                      selectDistrict,
                                      "chanukadias2@yahoo.com",
                                      0779873552,
                                      "961240999V",
                                      "Chanuka Dias",
                                      "https://firebasestorage.googleapis.com/v0/b/safeme-50a06.appspot.com/o/public%20profile%20images%2F961240999V?alt=media&token=3732ed11-39fa-4bc4-af5a-74678af19174",//"ProfileImage",
                                      selectDate,
                                      selectType);

                                  if (result = true) {
                                    EasyLoading.showSuccess(
                                        'Appointment Submitted successfully!',
                                        duration: Duration(seconds: 8));
                                    print(
                                        "******Appointment Submitted successfully!******");
                                    // EasyLoading.dismiss();
                                    Navigator.pop(context);
                                    Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => HomeBase()),
                                        (route) => false);
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

  Future<bool?> submitAppointment(
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
      String Type) async {
    final databaseRef = FirebaseDatabase.instance.ref();
    FirebaseStorage storage = FirebaseStorage.instance;

    ///Get Last Appointment ID -1st Step

    var get_AID = databaseRef.child("/Appointments/LastAID");
    DatabaseEvent event = await get_AID.once();
    int AID = (event.snapshot.value).hashCode + 1;
    print("************ Complaint ID = $AID**************");

    if (AID != null) {
      try {
        print("************Get Complaint ID = $AID");

        var data = {
          "AID": AID,
          "Address": Address,
          "City": City,
          "Description": Description,
          "District": District,
          "Email": Email,
          "Mobile": Mobile,
          "NIC": NIC,
          "Name": Name,
          "ProfileImage": ProfileImage,
          "RequestedDate": Date.toString(),
          "ScheduledDate": "Pending",
          "Type": Type
        };

        ///submit Appointment - 2nd Step

        databaseRef
            .child("/Appointments/PublicAppointments/")
            .child("$AID")
            .set(data);
        print("**************Save Appointment ");

        ///Update Appointment Count
        var getAppointmentCount =
            databaseRef.child("/Appointments/PublicAppointmentCount");
        DatabaseEvent event = await getAppointmentCount.once();
        print(event.snapshot.value);
        int Appointment_Count = (event.snapshot.value).hashCode + 1;
        databaseRef
            .child("/Appointments/")
            .update({'PublicAppointmentCount': Appointment_Count});

        ///Update Last Complaint ID
        databaseRef.child("/Appointments/").update({'LastAID': AID});

        return true;
      } catch (e) {
        print(e);
        return false;
      }
    } else {
      return false;
    }
  }
}
