import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:motion_toast/resources/arrays.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../../Controller/language_controller.dart';
import '../../Resources/colors.dart';
import '../../Resources/style.dart';
import '../../widgets/drawer.dart';
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
  late VideoPlayerController _videoPlayerController;
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


  late String selectDistrict;
  late String selectCity;
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

  // final _txtSubjectController = TextEditingController();
  // final _txtSubjectController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getCurrLocation();
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
                  FormBuilderDateTimePicker(
                    name: 'dateTime',
                    onChanged: (val) => setState(() {
                      selectDate = val!;
                    }),
                    inputType: InputType.both,
                    validator: (value) => value == null
                        ? "Enter Lost or Found Date & Time"
                        : null,
                    decoration: InputDecoration(
                      suffixIcon: Icon(Icons.date_range),
                      labelText: "DateTime".tr(),
                      labelStyle: hintTextStyle,
                      contentPadding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: secondary)),
                    ),

                    // initialTime: const TimeOfDay(hour: 12, minute: 0),
                    // initialValue: DateTime.now(),
                    lastDate: DateTime.now(),
                    firstDate: DateTime.now().add(Duration(days: -5)),

                    timePickerInitialEntryMode: TimePickerEntryMode.input,

                    // enabled: true,
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
                              if (_fbKey.currentState!.validate() &&
                                  _file1 != null &&
                                  _file2 != null) {
                                if (isAgree == true) {
                                  EasyLoading.show(status: "Submitting...");
                                  print("******Validate******");
                                  var result = await submitLostAndFound(
                                      "Address",
                                      selectCity,
                                      selectDate,
                                      _txtDescriptionController.text,
                                      selectDistrict,
                                      "Email",
                                      _file1 as File,
                                      //Image1,
                                      _file2 as File,
                                      //Image2,
                                      _position.latitude,
                                      _position.longitude,
                                      0779873552,
                                      //Mobile,
                                      "961240999V",
                                      //NIC,
                                      "Chanuka Anuruddha",
                                      //Name,
                                      ""
                                      //ProfileImage,
                                      );

                                  if (result = true) {
                                    // MotionToast.success(
                                    //   toastDuration: Duration(seconds: 4),
                                    //   title: Text("Success"),
                                    //   description: Text("Complaint Submitted successfully!"),
                                    //   animationType: AnimationType.slideInFromTop,
                                    //   toastAlignment: Alignment.topCenter,
                                    // ).show(context);

                                    EasyLoading.showSuccess(
                                        'Lost and Found Complaint Submitted successfully!',
                                        duration: Duration(seconds: 5));
                                    print(
                                        "******Complaint Submitted successfully!******");
                                    // EasyLoading.dismiss();
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

  Future<bool?> submitLostAndFound(
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
    final databaseRef = FirebaseDatabase.instance.ref();
    FirebaseStorage storage = FirebaseStorage.instance;

    ///Get Last Lost and Found ID -1st Step

    var get_CID = databaseRef.child("/Complaints/lastCID");
    DatabaseEvent event = await get_CID.once();
    int CID = (event.snapshot.value).hashCode + 1;
    print("************ Lost and Found Complaint ID = $CID**************");

    if (CID != null) {
      try {
        print("************Get Complaint ID = $CID");
        var data = {
          "CID": CID,
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
          "Type": "Lost And Found"
        };

        ///Save Complaint - 2nd Step

        databaseRef.child("/Complaints/All/").child("$CID").set(data);
        print("**************Save Lost and Found response ");

        /// update complaints image Url

        Reference ref_Im1 = storage.ref().child("/complaints/" + "$CID" "_1");
        await ref_Im1.putFile(Image1);
        Reference ref_Im2 = storage.ref().child("/complaints/" + "$CID" "_2");
        await ref_Im2.putFile(Image2);
        String image1Url = await ref_Im1.getDownloadURL();
        String image2Url = await ref_Im2.getDownloadURL();
        print("********Image_1 URL = $image1Url");
        print("********Image_2 URL = $image2Url");

        databaseRef
            .child("/Complaints/All/$CID")
            .update({'Image1': image1Url, 'Image2': image2Url});

        ///Update Last Lost and Found Complaint ID
        databaseRef.child("/Complaints/").update({'lastCID': CID});

        ///Update Lost and Found  Complaint Count
        var getComplaintCount = databaseRef.child("/Complaints/ComplaintCount");
        DatabaseEvent event = await getComplaintCount.once();
        print(event.snapshot.value);
        int Complaint_Count = (event.snapshot.value).hashCode + 1;
        databaseRef
            .child("/Complaints/")
            .update({'ComplaintCount': Complaint_Count});

        ///Update Lost and Found Count
        var getLostAndFoundCount =
            databaseRef.child("/Complaints/LostAndFoundCount");
        DatabaseEvent LFevent = await getLostAndFoundCount.once();
        print(event.snapshot.value);
        int LostAndFound_Count = (LFevent.snapshot.value).hashCode + 1;
        databaseRef
            .child("/Complaints/")
            .update({'LostAndFoundCount': LostAndFound_Count});

        // MotionToast.success(
        //   toastDuration: Duration(seconds: 4),
        //   title: Text("Success"),
        //   description: Text("Complaint Submitted successfully!"),
        //   animationType: AnimationType.slideInFromTop,
        //   toastAlignment: Alignment.topCenter,
        // ).show(context);

        return true;
      } catch (e) {
        print(e);
        return false;
      }
    }
  }
}
