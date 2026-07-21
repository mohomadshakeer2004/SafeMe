import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:safe_me/service/firebase_service.dart';
import 'package:safe_me/service/userService.dart';
import 'package:safe_me/util/user_data_util.dart';
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
import 'complaint_ui.dart';

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
    try {
      final databaseRef = FirebaseService.instance.rootRef;

      final event = await databaseRef
          .child('/Complaints/All/${widget.CID}')
          .once()
          .timeout(FirebaseService.rtdbTimeout);
      final snapshot = event.snapshot;

      if (!snapshot.exists || snapshot.value == null) {
        if (mounted) {
          setState(() {
            complaintData = {};
          });
        }
        return;
      }

      Map<String, dynamic> data =
          jsonDecode(jsonEncode(snapshot.value)) as Map<String, dynamic>;
      if (!mounted) return;
      setState(() {
        complaintData = data;
      });

      print(
          "************complaint Data= ${complaintData.values.toList()}**************");
    } catch (e) {
      debugPrint('Failed to load complaint: $e');
    } finally {
      EasyLoading.dismiss();
    }
  }

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
    } catch (e) {
      debugPrint('Failed to load user data: $e');
    } finally {
      EasyLoading.dismiss();
    }
  }

  String _complaintDateText(String pattern) {
    final raw = UserDataUtil.field(complaintData, 'Date');
    if (raw.isEmpty) return '';
    try {
      return DateFormat(pattern).format(DateTime.parse(raw));
    } catch (_) {
      return raw;
    }
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
      backgroundColor: appSurface,
      appBar: ComplaintUi.appBar(
        context: context,
        title: 'Description',
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
                  color: appSurfaceElevated,
                ),
                controller: _refreshController,
                onRefresh: _onRefresh,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ComplaintUi.sectionCard(
                          title: 'Complaint Summary',
                          child: Column(
                            children: [
                              ComplaintUi.detailRow(
                                'CID',
                                UserDataUtil.field(
                                  complaintData,
                                  'CID',
                                  fallback: widget.CID,
                                ),
                              ),
                              ComplaintUi.detailRow(
                                'District',
                                UserDataUtil.field(complaintData, 'District'),
                              ),
                              ComplaintUi.detailRow(
                                'City',
                                UserDataUtil.field(complaintData, 'City'),
                              ),
                              ComplaintUi.detailRow(
                                'Date',
                                _complaintDateText('yyyy-MM-dd'),
                              ),
                              ComplaintUi.detailRow(
                                'Time',
                                _complaintDateText('hh:mm a'),
                              ),
                              Row(
                                children: [
                                  SizedBox(
                                    width: 110,
                                    child: Text(
                                      'Status : ',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: secondary,
                                        fontFamily: 'Poppins-Bold',
                                      ),
                                    ),
                                  ),
                                  ComplaintUi.statusChip(
                                    UserDataUtil.field(
                                      complaintData,
                                      'Status',
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        ComplaintUi.sectionCard(
                          title: 'Details of the Complainant',
                          child: Column(
                            children: [
                              ComplaintUi.detailRow(
                                'Name',
                                UserDataUtil.field(userData, 'Name'),
                              ),
                              ComplaintUi.detailRow(
                                'NIC No',
                                UserDataUtil.field(
                                  userData,
                                  'NIC',
                                  fallback: widget.NIC,
                                ),
                              ),
                              ComplaintUi.detailRow(
                                'Email Address',
                                UserDataUtil.field(userData, 'Email'),
                              ),
                              ComplaintUi.detailRow(
                                'Mobile Number',
                                UserDataUtil.field(userData, 'Mobile'),
                              ),
                              ComplaintUi.detailRow(
                                'Address',
                                UserDataUtil.field(userData, 'Address'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        ComplaintUi.sectionCard(
                          title: 'Details of the Complaint',
                          child: Column(
                            children: [
                              ComplaintUi.detailRow(
                                'Type',
                                UserDataUtil.field(complaintData, 'Type'),
                              ),
                              ComplaintUi.detailRow(
                                'Description',
                                UserDataUtil.field(
                                  complaintData,
                                  'Description',
                                ),
                              ),
                              ComplaintUi.detailRow(
                                'Location',
                                '${UserDataUtil.field(complaintData, 'Latitude')} , ${UserDataUtil.field(complaintData, 'Longitude')}',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        ComplaintUi.sectionCard(
                          title: 'Evidence Of the Complaint',
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _evidenceImage(
                                sysWidth,
                                UserDataUtil.field(complaintData, 'Image1'),
                              ),
                              _evidenceImage(
                                sysWidth,
                                UserDataUtil.field(complaintData, 'Image2'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        ComplaintUi.sectionCard(
                          title: 'Comments of the Police',
                          child: Text(
                            UserDataUtil.field(complaintData, 'Reason'),
                            style: TextStyle(
                              fontSize: 13,
                              color: appTextMuted,
                              fontFamily: 'Poppins-Light',
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ComplaintUi.primaryButton(
                          label: 'Save PDF',
                          icon: Icons.picture_as_pdf,
                          width: double.infinity,
                          onTap: _CreatePDF,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _evidenceImage(double sysWidth, String imageUrl) {
    return Container(
      width: sysWidth / 3.2,
      height: sysWidth / 3.2,
      decoration: BoxDecoration(
        color: appSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: appBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              errorWidget: (context, url, error) =>
                  Icon(Icons.error, color: emergencyPrimary),
            )
          : const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
    );
  }

  Future<void> _CreatePDF() async {
    print("Save PDF");
    final pdfFile = await PdfApi.generateImage(
        UserDataUtil.field(userData, 'Address'),
        complaintData['CID'],
        complaintData['City'],
        complaintData['Date'],
        complaintData['Description'],
        complaintData['District'],
        UserDataUtil.field(userData, 'Email'),
        complaintData['Latitude'],
        complaintData['Longitude'],
        UserDataUtil.field(userData, 'Mobile'),
        UserDataUtil.field(userData, 'NIC'),
        UserDataUtil.field(userData, 'Name'),
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
