import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:motion_toast/resources/arrays.dart';
import 'package:provider/provider.dart';

import '../../Controller/language_controller.dart';
import '../../Resources/colors.dart';
import '../../data/sri_lanka_locations.dart';
import '../../service/firebase_service.dart';
import '../../service/userService.dart';
import '../../util/user_data_util.dart';
import '../../widgets/drawer.dart';
import '../../widgets/legal_acceptance_title.dart';
import '../../widgets/safe_date_field.dart';
import '../Complaint/complaint_ui.dart';
import 'appointment_base.dart';

class AppointmentForm extends StatefulWidget {
  const AppointmentForm({Key? key}) : super(key: key);

  @override
  _AppointmentFormState createState() => _AppointmentFormState();
}

class _AppointmentFormState extends State<AppointmentForm> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();

  String selectDistrict = '';
  String selectCity = '';
  String selectType = '';
  DateTime selectDate = DateTime.now();
  bool isAgree = false;

  final _txtDescriptionController = TextEditingController();
  Map<String, dynamic> userData = {};

  final appointmentTypes = [
    'Minor Complaints',
    'Minor Crime (Less than Rs.50,000)',
    'Crime',
    'Murder',
    'Traffic Viloation',
    'Crime against women & children',
    'Other',
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
    final sysWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: appSurface,
      appBar: ComplaintUi.appBar(
        context: context,
        title: 'Place_Appointment'.tr(),
        sysWidth: sysWidth,
        onBack: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AppointmentBase()),
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
              title: 'Appointment_Details'.tr(),
              child: Column(
                children: [
                  FormBuilderDropdown(
                    onChanged: (val) => setState(() {
                      selectDistrict = val?.toString() ?? '';
                      selectCity = '';
                      _fbKey.currentState?.fields['city']?.didChange(null);
                    }),
                    name: 'district',
                    decoration: ComplaintUi.fieldDecoration('district'.tr()),
                    validator: (value) =>
                        value == null || value.toString().isEmpty
                            ? 'Enter Your District'
                            : null,
                    items: SriLankaLocations.dropdownItems(
                      SriLankaLocations.districts,
                    ),
                  ),
                  const SizedBox(height: 14),
                  FormBuilderDropdown(
                    key: ValueKey('city_$selectDistrict'),
                    enabled: selectDistrict.isNotEmpty,
                    onChanged: (val) => setState(() {
                      selectCity = val?.toString() ?? '';
                    }),
                    name: 'city',
                    decoration: ComplaintUi.fieldDecoration('City'.tr()),
                    validator: (value) =>
                        value == null || value.toString().isEmpty
                            ? 'Enter Your City'
                            : null,
                    items: SriLankaLocations.dropdownItems(
                      SriLankaLocations.citiesForDistrict(selectDistrict),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SafeDateField(
                    name: 'requestDateTime',
                    labelText: 'RequestDateTime'.tr(),
                    labelStyle: TextStyle(
                      color: appTextMuted,
                      fontFamily: 'Poppins-Light',
                    ),
                    focusColor: secondary,
                    includeTime: true,
                    firstDate: DateTime.now(),
                    onChanged: (val) => setState(() {
                      if (val != null) selectDate = val;
                    }),
                    validator: (value) =>
                        value == null ? 'Enter Required Date & Time' : null,
                  ),
                  const SizedBox(height: 14),
                  FormBuilderDropdown(
                    onChanged: (val) => setState(() {
                      selectType = val.toString();
                    }),
                    name: 'type',
                    validator: (value) =>
                        value == null ? 'Select Your Appointment Type' : null,
                    decoration:
                        ComplaintUi.fieldDecoration('AppointmentType'.tr()),
                    items: appointmentTypes
                        .map(
                          (type) => DropdownMenuItem(
                            alignment: AlignmentDirectional.centerStart,
                            value: type,
                            child: Text(type),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 14),
                  FormBuilderTextField(
                    cursorColor: secondary,
                    minLines: 4,
                    maxLines: 8,
                    name: 'description',
                    validator: (value) =>
                        value!.isEmpty ? 'Description is Required' : null,
                    controller: _txtDescriptionController,
                    decoration:
                        ComplaintUi.fieldDecoration('Description'.tr()),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            FormBuilderCheckbox(
              onChanged: (val) => setState(() {
                isAgree = val == true;
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
              onTap: _submitForm,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    try {
      if (!_fbKey.currentState!.validate()) return;

      if (!isAgree) {
        MotionToast.error(
          title: const Text('Error'),
          description: Text('Please Agree to Terms & Condition'),
          animationType: AnimationType.slideInFromLeft,
          toastAlignment: Alignment.topCenter,
        ).show(context);
        return;
      }

      final nic = UserDataUtil.field(userData, 'NIC');
      if (nic.isEmpty) {
        MotionToast.error(
          title: const Text('Error'),
          description: const Text(
            'User profile not loaded. Please try again.',
          ),
          animationType: AnimationType.slideInFromLeft,
          toastAlignment: Alignment.topCenter,
        ).show(context);
        return;
      }

      EasyLoading.show(status: 'Submitting'.tr());

      final result = await submitAppointment(
        UserDataUtil.field(userData, 'Address'),
        selectCity,
        _txtDescriptionController.text,
        selectDistrict,
        UserDataUtil.field(userData, 'Email'),
        UserDataUtil.mobileAsInt(userData),
        nic,
        UserDataUtil.field(userData, 'Name'),
        UserDataUtil.field(userData, 'ProfileImage'),
        selectDate,
        selectType,
      );

      EasyLoading.dismiss();
      if (!mounted) return;

      if (result == true) {
        EasyLoading.showSuccess(
          'Appointment_Submitted'.tr(),
          duration: const Duration(seconds: 3),
        );
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const AppointmentBase()),
          (route) => false,
        );
      } else {
        EasyLoading.showError('Appointment_Submit_Failed'.tr());
      }
    } catch (e) {
      EasyLoading.dismiss();
      debugPrint('$e');
    }
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

      final data = {
        'AID': aid,
        'Address': Address,
        'City': City,
        'Description': Description,
        'District': District,
        'Email': Email,
        'Mobile': Mobile,
        'NIC': nicKey,
        'Name': Name,
        'ProfileImage': ProfileImage,
        'RequestedDate': Date.toString(),
        'ScheduledDate': 'Pending',
        'Status': 'Active',
        'Type': Type,
      };

      await databaseRef
          .child('/Appointments/PublicAppointments/Records/$aid')
          .set(data)
          .timeout(timeout);

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
      debugPrint('$e');
      return false;
    }
  }
}
