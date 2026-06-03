import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:safe_me/service/firebase_service.dart';
import 'package:safe_me/service/userService.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:safe_me/Screens/Complaint/pdf_api.dart';
import '../../Controller/language_controller.dart';
import '../../Resources/colors.dart';
import '../../Resources/style.dart';
import '../../widgets/drawer.dart';
import 'complaint_base.dart';

class SingleSubmissionScreen extends StatefulWidget {
  const SingleSubmissionScreen(this.CID, this.NIC);

  final String CID;
  final String NIC;

  @override
  _SingleSubmissionScreenState createState() => _SingleSubmissionScreenState();
}

class _SingleSubmissionScreenState extends State<SingleSubmissionScreen> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  final GlobalKey<FormBuilderState> _fbKeyValidation =
      GlobalKey<FormBuilderState>();
  var submissionModel;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void _onRefresh() async {
    print("REFRESH STARTED");
    _refreshController.refreshCompleted();
    getUserData();
    getComplaintData();
    print("REFRESH STOPPED");
  }

  List<Widget> indicators(imagesLength, currentIndex) {
    return List<Widget>.generate(imagesLength, (index) {
      return Container(
        margin: EdgeInsets.all(3),
        width: 5,
        height: 5,
        decoration: BoxDecoration(
            color: currentIndex == index ? Colors.black : Colors.black26,
            shape: BoxShape.circle),
      );
    });
  }

  int activePage = 0;

  TextEditingController _txtDescriptionController = TextEditingController();

  Map<String, dynamic> complaintData = {};
  Map<String, dynamic> userData = {};

  getComplaintData() async {
    EasyLoading.show(status: "Getting Complaint Data");
    final databaseRef = FirebaseService.instance.rootRef;

    var get_UserData = databaseRef.child('/Complaints/All').child(widget.CID);
    DatabaseEvent event = await get_UserData.once();

    Map<String, dynamic> data =
        jsonDecode(jsonEncode(event.snapshot.value)) as Map<String, dynamic>;
    setState(() {
      complaintData = data;
    });

    print(
        "************complaint Data= ${complaintData.values.toList()}**************");
  }

  getUserData() async {
    final nic = await UserService().requireLoggedInNic();
    if (nic == null) return;
    EasyLoading.show(status: "Getting User Data");
    final databaseRef = FirebaseService.instance.rootRef;

    var get_UserData = databaseRef.child('/PublicUsers/All/').child(nic);
    DatabaseEvent event = await get_UserData.once();
    String aa = (event.snapshot.value).toString();
    // EasyLoading.dismiss();
    Map<String, dynamic> data =
        jsonDecode(jsonEncode(event.snapshot.value)) as Map<String, dynamic>;
    setState(() {
      userData = data;
    });

    print("************ User Data = ${data}**************");
  }

  @override
  void initState() {
    super.initState();
    getUserData();
    getComplaintData();
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
          "Description",
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
                      builder: (context) => const ComplaintHome()));
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: DrawerWidget(),
      ),
      body: Container(
        height: sysHeight,
        width: sysWidth,
        child: submissionModel != null
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : SmartRefresher(
                enablePullDown: true,
                // enablePullUp: true,
                header: WaterDropMaterialHeader(
                  backgroundColor: secondary,
                  color: mainBGColor,
                ),
                controller: _refreshController,
                onRefresh: _onRefresh,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: '',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              "CID : ",
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: textBlackColor,
                                                fontFamily: 'Poppins-Bold',
                                              ),
                                            ),
                                            Flexible(
                                              child: Text(
                                                complaintData['CID'].toString(),
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  // fontWeight: FontWeight.bold,
                                                  color: textBlackColor,
                                                  fontFamily: 'Poppins-Light',
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              "District : ",
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: textBlackColor,
                                                fontFamily: 'Poppins-Bold',
                                              ),
                                            ),
                                            Flexible(
                                              child: Text(
                                                complaintData['District']
                                                    .toString(),
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  // fontWeight: FontWeight.bold,
                                                  color: textBlackColor,
                                                  fontFamily: 'Poppins-Light',
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              "City : ",
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: textBlackColor,
                                                fontFamily: 'Poppins-Bold',
                                              ),
                                            ),
                                            Flexible(
                                              child: Text(
                                                complaintData['City']
                                                    .toString(),
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  // fontWeight: FontWeight.bold,
                                                  color: textBlackColor,
                                                  fontFamily: 'Poppins-Light',
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              "Date : ",
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: textBlackColor,
                                                fontFamily: 'Poppins-Bold',
                                              ),
                                            ),
                                            Flexible(
                                              child: Text(
                                                DateFormat('yyyy-MM-dd').format(
                                                    DateTime.parse(
                                                        complaintData['Date']
                                                            .toString())),
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  // fontWeight: FontWeight.bold,
                                                  color: textBlackColor,
                                                  fontFamily: 'Poppins-Light',
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              "Time : ",
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: textBlackColor,
                                                fontFamily: 'Poppins-Bold',
                                              ),
                                            ),
                                            Flexible(
                                              child: Text(
                                                DateFormat('hh:mm a').format(
                                                    DateTime.parse(
                                                        complaintData['Date']
                                                            .toString())),
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  // fontWeight: FontWeight.bold,
                                                  color: textBlackColor,
                                                  fontFamily: 'Poppins-Light',
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              "Status : ",
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: textBlackColor,
                                                fontFamily: 'Poppins-Bold',
                                              ),
                                            ),
                                            Flexible(
                                              child: Text(
                                                complaintData['Status']
                                                    .toString(),
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  // fontWeight: FontWeight.bold,
                                                  color: textBlackColor,
                                                  fontFamily: 'Poppins-Light',
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Container(
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Details of the Complainant',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      "Name : ",
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: textBlackColor,
                                        fontFamily: 'Poppins-Bold',
                                      ),
                                    ),
                                    Flexible(
                                      child: Text(
                                        userData['Name'],
                                        style: TextStyle(
                                          fontSize: 15,
                                          // fontWeight: FontWeight.bold,
                                          color: textBlackColor,
                                          fontFamily: 'Poppins-Light',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "NIC No : ",
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: textBlackColor,
                                        fontFamily: 'Poppins-Bold',
                                      ),
                                    ),
                                    Flexible(
                                      child: Text(
                                        userData['NIC'],
                                        style: TextStyle(
                                          fontSize: 15,
                                          // fontWeight: FontWeight.bold,
                                          color: textBlackColor,
                                          fontFamily: 'Poppins-Light',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "Email Address : ",
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: textBlackColor,
                                        fontFamily: 'Poppins-Bold',
                                      ),
                                    ),
                                    Flexible(
                                      child: Text(
                                        userData['Email'],
                                        style: TextStyle(
                                          fontSize: 15,
                                          // fontWeight: FontWeight.bold,
                                          color: textBlackColor,
                                          fontFamily: 'Poppins-Light',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "Mobile Number : ",
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: textBlackColor,
                                        fontFamily: 'Poppins-Bold',
                                      ),
                                    ),
                                    Flexible(
                                      child: Text(
                                        userData['Mobile'],
                                        style: TextStyle(
                                          fontSize: 15,
                                          // fontWeight: FontWeight.bold,
                                          color: textBlackColor,
                                          fontFamily: 'Poppins-Light',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Address : ",
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: textBlackColor,
                                        fontFamily: 'Poppins-Bold',
                                      ),
                                    ),
                                    Flexible(
                                      child: Text(
                                        userData['Address'],
                                        style: TextStyle(
                                          fontSize: 15,
                                          // fontWeight: FontWeight.bold,
                                          color: textBlackColor,
                                          fontFamily: 'Poppins-Light',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Container(
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Details of the Complaint',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      "Type : ",
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: textBlackColor,
                                        fontFamily: 'Poppins-Bold',
                                      ),
                                    ),
                                    Flexible(
                                      child: Text(
                                        complaintData['Type'].toString(),
                                        style: TextStyle(
                                          fontSize: 15,
                                          // fontWeight: FontWeight.bold,
                                          color: textBlackColor,
                                          fontFamily: 'Poppins-Light',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Description : ",
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: textBlackColor,
                                        fontFamily: 'Poppins-Bold',
                                      ),
                                    ),
                                    Flexible(
                                      child: Text(
                                        complaintData['Description'].toString(),
                                        style: TextStyle(
                                          fontSize: 15,
                                          // fontWeight: FontWeight.bold,
                                          color: textBlackColor,
                                          fontFamily: 'Poppins-Light',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Location : ",
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: textBlackColor,
                                        fontFamily: 'Poppins-Bold',
                                      ),
                                    ),
                                    Flexible(
                                      child: Text(
                                        "${complaintData['Latitude'].toString()} , ${complaintData['Longitude'].toString()}",
                                        style: TextStyle(
                                          fontSize: 15,
                                          // fontWeight: FontWeight.bold,
                                          color: textBlackColor,
                                          fontFamily: 'Poppins-Light',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Container(
                          width: sysWidth,
                          // /height: 200,
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Evidence Of the Complaint',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Container(
                                  child: complaintData['Image1'] != null
                                      ? CachedNetworkImage(
                                          imageUrl: complaintData['Image1']
                                              .toString(),
                                          width: sysWidth / 3,
                                          placeholder: (context, url) =>
                                              Container(
                                            width: 20,
                                            height: 20,
                                            child: const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            ),
                                          ),
                                          errorWidget: (context, url, error) =>
                                              Icon(Icons.error),
                                        )
                                      : Container(
                                          width: 20,
                                          height: 20,
                                          child: const Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        ),

                                  //Image.network(images[pagePosition]),
                                ),
                                Container(
                                  child: complaintData['Image2'] != null
                                      ? CachedNetworkImage(
                                          imageUrl: complaintData['Image2']
                                              .toString(),
                                          width: sysWidth / 3,
                                          placeholder: (context, url) =>
                                              Container(
                                            width: 20,
                                            height: 20,
                                            child: const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            ),
                                          ),
                                          errorWidget: (context, url, error) =>
                                              Icon(Icons.error),
                                        )
                                      : Container(
                                          width: 20,
                                          height: 20,
                                          child: const Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        ),

                                  //Image.network(images[pagePosition]),
                                )
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Container(
                          width: sysWidth,
                          // /height: 200,
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Comments of the Police',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            child: Text(
                              complaintData['Reason'].toString(),
                              style: TextStyle(
                                fontSize: 15,
                                // fontWeight: FontWeight.bold,
                                color: textBlackColor,
                                fontFamily: 'Poppins-Light',
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        InkWell(
                            onTap: _CreatePDF,
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(3),
                                color: secondary,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "Save PDF",
                                    style: buttonTextStyle,
                                  ),
                                  Icon(
                                    Icons.picture_as_pdf,
                                    color: normalTextColor,
                                  ),
                                ],
                              ),
                            )),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Future<void> _CreatePDF() async {
    print("Save PDF");
    final pdfFile = await PdfApi.generateImage(
        userData['Address'],
        complaintData['CID'],
        complaintData['City'],
        complaintData['Date'],
        complaintData['Description'],
        complaintData['District'],
        userData['Email'],
        complaintData['Latitude'],
        complaintData['Longitude'],
        userData['Mobile'],
        userData['NIC'],
        userData['Name'],
        complaintData['Reason'].toString(),
        complaintData['Status'],
        complaintData['Type']);
    PdfApi.openFile(pdfFile);
  }
}

/*
Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          Expanded(
                            flex: 10,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: PageView.builder(
                                  itemCount: images.length,
                                  pageSnapping: true,
                                  controller: _pageController,
                                  onPageChanged: (page) {
                                    setState(() {
                                      activePage = page;
                                    });
                                  },
                                  itemBuilder: (context, pagePosition) {
                                    return Container(
                                      child: images.isNotEmpty
                                          ? CachedNetworkImage(
                                              imageUrl: images[pagePosition],
                                              placeholder: (context, url) =>
                                                  Container(
                                                width: 20,
                                                height: 20,
                                                child: const Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                ),
                                              ),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Icon(Icons.error),
                                            )
                                          : Container(
                                              width: 20,
                                              height: 20,
                                              child: const Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              ),
                                            ),

                                      //Image.network(images[pagePosition]),
                                    );
                                  }),
                            ),
                          ),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: indicators(images.length, activePage),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(flex: 4,
                      child: FormBuilder(
                        key: _fbKey,
                        child:SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                /*
                                FormBuilderTextField(
                                 // enabled: false,
                                  readOnly: true,
                                  name: 'CID',
                                   controller: _txtCIDController,
                                  decoration: InputDecoration(
                                    labelText: "CID",
                                    labelStyle: hintTextStyle,
                                    contentPadding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                                    border: OutlineInputBorder(),
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: secondary)),
                                  ),
                                ),
                                const SizedBox(height: 15),
                                FormBuilderTextField(
                                  // enabled: false,
                                  readOnly: true,
                                  name: 'type',
                                  controller: _txtTypeController,
                                  decoration: InputDecoration(
                                    labelText: "Type",
                                    labelStyle: hintTextStyle,
                                    contentPadding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                                    border: OutlineInputBorder(),
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: secondary)),
                                  ),
                                ),
                                const SizedBox(height: 15),
                                FormBuilderTextField(
                                  minLines: 3,
                                  maxLines: 5,
                                  // enabled: false,
                                  readOnly: true,
                                  name: 'description',
                                  controller: _txtDescriptionController,
                                  decoration: InputDecoration(
                                    labelText: "Description",
                                    labelStyle: hintTextStyle,
                                    contentPadding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                                    border: OutlineInputBorder(),
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: secondary)),
                                  ),
                                ),
                                const SizedBox(height: 15),
                                FormBuilderTextField(
                                  // enabled: false,
                                  readOnly: true,
                                  name: 'address',
                                  controller: _txtAddressController,
                                  decoration: InputDecoration(
                                    labelText: "Address",
                                    labelStyle: hintTextStyle,
                                    contentPadding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                                    border: OutlineInputBorder(),
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: secondary)),
                                  ),
                                ),


                                 */


                              ],
                            ),
                          ),
                        ),
                      ),),
 */
