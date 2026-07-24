import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:motion_toast/resources/arrays.dart';
import 'package:provider/provider.dart';
import 'package:motion_toast/motion_toast.dart';
import '../../Controller/language_controller.dart';
import '../../Resources/colors.dart';
import '../../Resources/style.dart';
import '../../service/firebase_service.dart';
import '../../util/user_data_util.dart';
import 'LoginPage.dart';
import 'signupPage2.dart';

class SignupScreen1 extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen1> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  final GlobalKey<FormBuilderState> _fbKeyValidation =
      GlobalKey<FormBuilderState>();

  late List<int> profileImage;
  File? image;

  XFile? _imageFile = null;
  final ImagePicker _picker = ImagePicker();

  /// Shown under the NIC field when that ID is already registered.
  String? _nicTakenError;
  bool _checkingNic = false;

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
              backgroundColor: Colors.white,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              builder: (sheetContext) => bottomSheet(sheetContext),
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

  final _txtFNameController = TextEditingController();
  final _txtLNameController = TextEditingController();
  final _txtEmailController = TextEditingController();
  final _txtMobNoController = TextEditingController();
  final _txtNicController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    context.watch<LanguageController>();
    double sysWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: mainBGColor,
      appBar: AppBar(
        backgroundColor: mainBGColor,
        elevation: 0,
        iconTheme: IconThemeData(
          color: buttonColor, //change your color here
        ),
      ),
      body: SafeArea(
        child: FormBuilder(
            //autovalidateMode: AutovalidateMode.onUserInteraction,
            key: _fbKey,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: ListView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  Image.asset(
                    "assets/images/logo.png",
                    height: sysWidth * 0.25,
                  ),
                          const SizedBox(height: 40),
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              "Welcome".tr(),
                              style: TextStyle(
                                fontSize: 25,
                                color: textBlackColor,
                                fontFamily: 'Poppins-Regular',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              "Sign_Up_txt".tr(),
                              style: TextStyle(
                                fontSize: 16,
                                color: textBlackColor,
                                fontFamily: 'Poppins-Light',
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          CircleAvatar(
                            radius: 46,
                            backgroundColor: secondary,
                            child: _imageFile != null
                                ? getCircleAvatarWidget(
                                    FileImage(File(_imageFile!.path)))
                                : getCircleAvatarWidget(
                                    AssetImage("assets/images/no-profile.png"),
                                  ),
                          ),
                          const SizedBox(height: 30),
                          FormBuilderTextField(
                            textCapitalization: TextCapitalization.words,
                            name: "fName",
                            style: normalWhiteTextStyle,
                            keyboardType: TextInputType.name,
                            cursorColor: iconColor,
                            autofocus: false,
                            controller: _txtFNameController,
                            validator: (value) => value!.isEmpty
                                ? 'Enter Your First Name'
                                : (RegExp(r'[!@#<>?":_`~;[\]\\|=+)(*&^%0-9-]'))
                                        .hasMatch(value)
                                    ? 'Enter a Valid Name'
                                    : null,

                            //     (value){
                            //   if(value!.isEmpty){
                            //     return ("Please Enter Your First Name");
                            //   }
                            //   if(value!.characters.){
                            //
                            //   }
                            // },
                            decoration: InputDecoration(
                              contentPadding:
                                  const EdgeInsets.fromLTRB(20, 10, 20, 10),
                              border: OutlineInputBorder(
                                  // borderRadius: BorderRadius.circular(10)
                                  ),
                              focusedBorder: OutlineInputBorder(
                                  //  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: secondary)),
                              labelText: "FName".tr(),
                              labelStyle: hintTextStyle,
                            ),
                          ),
                          const SizedBox(height: 30),
                          FormBuilderTextField(
                            name: "lName",
                            style: normalWhiteTextStyle,
                            textCapitalization: TextCapitalization.words,
                            keyboardType: TextInputType.name,
                            autofocus: false,
                            controller: _txtLNameController,
                            validator: (value) => value!.isEmpty
                                ? 'Enter Your Last Name'
                                : (RegExp(r'[!@#<>?":_`~;[\]\\|=+)(*&^%0-9-]'))
                                        .hasMatch(value)
                                    ? 'Enter a Valid Name'
                                    : null,
                            decoration: InputDecoration(
                              labelText: "LName".tr(),
                              labelStyle: hintTextStyle,
                              contentPadding:
                                  const EdgeInsets.fromLTRB(20, 10, 20, 10),
                              border: OutlineInputBorder(
                                  // borderRadius: BorderRadius.circular(10)
                                  ),
                              focusedBorder: OutlineInputBorder(
                                  //  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: secondary)),
                            ),
                          ),
                          const SizedBox(height: 30),
                          FormBuilderTextField(
                            name: "nic",
                            style: normalWhiteTextStyle,
                            textCapitalization: TextCapitalization.characters,
                            keyboardType: TextInputType.text,
                            autofocus: false,
                            controller: _txtNicController,
                            onChanged: (_) {
                              // Clear any previous "taken" message while typing a new ID.
                              if (_nicTakenError != null || _checkingNic) {
                                setState(() {
                                  _nicTakenError = null;
                                  _checkingNic = false;
                                });
                              }
                            },
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Enter Your NIC No';
                              }
                              if (!UserDataUtil.isValidNic(value)) {
                                return 'Enter a Valid NIC No';
                              }
                              // Only after an explicit check marked this NIC as taken.
                              if (_nicTakenError != null) {
                                return _nicTakenError;
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: "NIC".tr(),
                              labelStyle: hintTextStyle,
                              contentPadding:
                                  EdgeInsets.fromLTRB(20, 10, 20, 10),
                              errorMaxLines: 3,
                              border: OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: secondary)),
                              errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: emergencyPrimary),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: emergencyPrimary,
                                  width: 1.5,
                                ),
                              ),
                              suffixIcon: _checkingNic
                                  ? const Padding(
                                      padding: EdgeInsets.all(12),
                                      child: SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    )
                                  : _nicTakenError != null
                                      ? Icon(Icons.error_outline,
                                          color: emergencyPrimary)
                                      : null,
                            ),
                          ),
                          if (_nicTakenError != null) ...[
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: emergencyPrimary.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color:
                                      emergencyPrimary.withValues(alpha: 0.35),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.info_outline,
                                      color: emergencyPrimary, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _nicTakenError!,
                                      style: TextStyle(
                                        color: emergencyPrimary,
                                        fontSize: 13,
                                        fontFamily: 'Poppins-Light',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 30),
                          FormBuilderTextField(
                            name: "email",
                            style: normalWhiteTextStyle,
                            keyboardType: TextInputType.emailAddress,
                            autofocus: false,
                            controller: _txtEmailController,
                            validator: (value) => value!.isEmpty
                                ? 'Enter Your email'
                                : (RegExp(r'^.+@[a-zA-Z]+\.{1}[a-zA-Z]+(\.{0,1}[a-zA-Z]+)$'))
                                        .hasMatch(value)
                                    ? null
                                    : 'Enter a Valid email',
                            decoration: InputDecoration(
                              labelText: "Email".tr(),
                              labelStyle: hintTextStyle,
                              contentPadding:
                                  EdgeInsets.fromLTRB(20, 10, 20, 10),
                              border: OutlineInputBorder(
                                  // borderRadius: BorderRadius.circular(10)
                                  ),
                              focusedBorder: OutlineInputBorder(
                                  //   borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: secondary)),
                            ),
                          ),
                          const SizedBox(height: 30),
                          FormBuilderTextField(
                            name: "mobile",
                            style: normalWhiteTextStyle,
                            keyboardType: TextInputType.phone,
                            autofocus: false,
                            maxLength: 10,
                            controller: _txtMobNoController,
                            validator: (value) => value!.isEmpty
                                ? 'Enter Your Mobile Number'
                                : value.length == 10
                                    ? null
                                    : 'Enter Valid Mobile Number',
                            decoration: InputDecoration(
                              labelText: "Mobile_No".tr(),
                              labelStyle: hintTextStyle,
                              contentPadding:
                                  EdgeInsets.fromLTRB(20, 10, 20, 10),
                              border: OutlineInputBorder(
                                  //  borderRadius: BorderRadius.circular(10)
                                  ),
                              focusedBorder: OutlineInputBorder(
                                  // borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: secondary)),
                            ),
                          ),
                          const SizedBox(height: 30),
                          InkWell(
                            onTap: () async {
                              if (!_fbKey.currentState!.validate()) {
                                print("******Not Validate******");
                                return;
                              }
                              if (_imageFile == null) {
                                MotionToast.error(
                                  title: Text("Error"),
                                  description: Text(
                                      "Please Select your Profile Image"),
                                  animationType: AnimationType.slideInFromLeft,
                                  toastAlignment: Alignment.topCenter,
                                ).show(context);
                                return;
                              }

                              final nic = UserDataUtil.normalizeNic(
                                  _txtNicController.text);
                              final status = await _checkNicAvailability();
                              if (!mounted) return;

                              // ONLY block when Firebase confirms this NIC exists.
                              if (status == _NicCheckStatus.taken) {
                                await showDialog<void>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('ID already in use'),
                                    content: Text(
                                      'This NIC / ID ($nic) is already registered.\n\n'
                                      'Please sign in with that account, or use a different NIC.',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(ctx),
                                        child: const Text('OK'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(ctx);
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => LoginPage(),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          'Login'.tr(),
                                          style: TextStyle(color: secondary),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                                return;
                              }

                              // New ID, or check could not run — allow continue.
                              // Final signup page re-checks before saving.
                              if (status == _NicCheckStatus.invalid) {
                                return;
                              }

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SignupScreen2(
                                    _txtFNameController.text,
                                    _txtLNameController.text,
                                    nic,
                                    _txtMobNoController.text,
                                    _txtEmailController.text,
                                    _imageFile!.path.toString(),
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(3),
                                color: buttonColor,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "Next".tr(),
                                    style: buttonTextStyle,
                                  )
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Already_have_an_account".tr(),
                                style: blackNormalTextStyle,
                              ),
                              InkWell(
                                onTap: () {
                                  print('Pressed  Login');
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => LoginPage(),
                                      ));
                                },
                                child: Text(
                                  "Login".tr(),
                                  style: blackNormalBoldTextStyle,
                                ),
                              ),
                            ],
                          ),
                  const SizedBox(height: 40),
                ],
              ),
            )),
      ),
    );
  }

  /// Checks Firebase. [taken] ONLY when a user record exists for this NIC.
  Future<_NicCheckStatus> _checkNicAvailability() async {
    final raw = _txtNicController.text;
    if (!UserDataUtil.isValidNic(raw)) {
      setState(() => _nicTakenError = null);
      return _NicCheckStatus.invalid;
    }

    final nic = UserDataUtil.normalizeNic(raw);
    setState(() {
      _checkingNic = true;
      _nicTakenError = null;
    });

    try {
      final taken = await FirebaseService.instance.isNicRegistered(nic);
      if (!mounted) return _NicCheckStatus.error;

      if (taken == true) {
        setState(() {
          _checkingNic = false;
          _nicTakenError =
              'This ID ($nic) is already registered. Please login or use another NIC.';
        });
        _fbKey.currentState?.fields['nic']?.validate();
        return _NicCheckStatus.taken;
      }

      // New / free ID — clear any error and continue.
      setState(() {
        _checkingNic = false;
        _nicTakenError = null;
      });
      return _NicCheckStatus.available;
    } catch (e) {
      debugPrint('NIC check failed: $e');
      if (!mounted) return _NicCheckStatus.error;
      // Do not show "already in use" on failure — treat as available for now.
      setState(() {
        _checkingNic = false;
        _nicTakenError = null;
      });
      return _NicCheckStatus.available;
    }
  }

  Widget bottomSheet(BuildContext sheetContext) {
    final bottomInset = MediaQuery.of(sheetContext).viewPadding.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 24, 24, bottomInset + 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _photoSheetOption(
            icon: Icons.camera_alt,
            label: "Camera",
            onTap: () => takePhoto(ImageSource.camera),
          ),
          const SizedBox(height: 16),
          _photoSheetOption(
            icon: Icons.image,
            label: "Gallery",
            onTap: () => takePhoto(ImageSource.gallery),
          ),
        ],
      ),
    );
  }

  Widget _photoSheetOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Icon(icon, color: IconColor2, size: 26),
            const SizedBox(width: 14),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: IconColor2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void takePhoto(ImageSource source) async {
    Navigator.of(context).pop();
    final pickedFile = await _picker.pickImage(
      source: source,
    );
    setState(() {
      if (pickedFile != null) {
        _imageFile = pickedFile;
      }
    });
  }
}

enum _NicCheckStatus { available, taken, invalid, error }
