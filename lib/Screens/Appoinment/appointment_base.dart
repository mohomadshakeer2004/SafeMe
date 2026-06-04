import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:safe_me/util/date_parse_util.dart';
import 'package:safe_me/service/firebase_service.dart';
import 'package:safe_me/service/userService.dart';
import 'package:safe_me/util/user_data_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
// import 'package:safe_me/Screens/Schedule/appoinmentForm.dart';

import '../../Controller/language_controller.dart';
import '../../Resources/colors.dart';
import '../../widgets/drawer.dart';
import '../Complaint/singleSubmission.dart';
import '../home_base.dart';
import 'appoinmentForm.dart';

class AppointmentBase extends StatefulWidget {
  const AppointmentBase({Key? key}) : super(key: key);

  @override
  _AppointmentBaseState createState() => _AppointmentBaseState();
}

class _AppointmentBaseState extends State<AppointmentBase> {
  /// Fixed card height (appointments have no image panel like complaints).
  static const double _appointmentCardHeight = 120;

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  List<Map<String, dynamic>> myPublicAppointments = [];
  List<Map<String, dynamic>> myPoliceAppointments = [];

  String _publicAppointmentId(Map<String, dynamic> item) =>
      '${item['AID'] ?? item['aid'] ?? ''}';

  String _policeAppointmentId(Map<String, dynamic> item) =>
      '${item['AIDP'] ?? item['AID'] ?? item['aid'] ?? ''}';

  /// Same proportions as complaint history: flex 1 / 4 / 10.
  Widget _complaintStyleIdStrip(String label) {
    return Expanded(
      flex: 1,
      child: Container(
        color: secondary,
        height: double.infinity,
        child: Center(
          child: RotatedBox(
            quarterTurns: 3,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: normalTextColor,
                fontFamily: 'Poppins-Bold',
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _loadAppointments() async {
    EasyLoading.show(status: "Getting Appointment Data");
    try {
      final sessionOk = await UserService().checkSession();
      if (!sessionOk) {
        if (mounted) {
          setState(() {
            myPublicAppointments = [];
            myPoliceAppointments = [];
          });
        }
        return;
      }

      final nic = await UserService().getLoggedInNic();
      if (nic == null || nic.isEmpty) {
        if (mounted) {
          setState(() {
            myPublicAppointments = [];
            myPoliceAppointments = [];
          });
        }
        return;
      }

      final firebase = FirebaseService.instance;
      String? email;
      try {
        final userSnap = await firebase.getPublicUser(nic);
        if (userSnap.exists && userSnap.value is Map) {
          final userMap = UserDataUtil.withDefaults(
            jsonDecode(jsonEncode(userSnap.value)) as Map<String, dynamic>,
            nic,
          );
          email = UserDataUtil.field(userMap, 'Email');
        }
      } catch (_) {}

      final public =
          await firebase.fetchMyPublicAppointments(nic, email: email);
      final police =
          await firebase.fetchMyPoliceAppointments(nic, email: email);

      if (!mounted) return;
      setState(() {
        myPublicAppointments = public;
        myPoliceAppointments = police;
      });

      debugPrint(
          'My appointments ($nic): public=${public.length}, police=${police.length}');
    } catch (e) {
      debugPrint('Failed to load appointments: $e');
      if (mounted) {
        setState(() {
          myPublicAppointments = [];
          myPoliceAppointments = [];
        });
      }
    } finally {
      EasyLoading.dismiss();
    }
  }

  void _onRefresh() async {
    await _loadAppointments();
    _refreshController.refreshCompleted();
  }

  @override
  void initState() {
    super.initState();
    _loadAppointments();
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
          "MyAppointment".tr(),
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            // flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AppointmentForm()),
                  ).then((_) {
                    if (mounted) _loadAppointments();
                  });
                },
                child: Container(
                  height: sysHeight / 20 * 1.5,
                  width: sysWidth,
                  decoration: BoxDecoration(
                    color: secondary,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 15, right: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Place_Appointment".tr(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 20,
                              color: normalTextColor,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins-Medium'),
                        ),
                        Icon(
                          Icons.add_circle_outline_sharp,
                          color: normalTextColor,
                          size: 35,
                        )
                        // ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 7,
            child: DefaultTabController(
              length: 2,
              child: SizedBox(
                height: 100.0,
                child: Column(
                  children: <Widget>[
                    TabBar(
                      indicatorColor: secondary,
                      labelColor: secondary,
                      tabs: <Widget>[
                        Tab(
                          text: "History",
                        ),
                        Tab(
                          text: "Police ",
                        )
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: <Widget>[
                          Container(
                            child: SmartRefresher(
                              enablePullDown: true,
                              enablePullUp: true,
                              header: WaterDropMaterialHeader(
                                backgroundColor: secondary,
                                color: mainBGColor,
                              ),
                              controller: _refreshController,
                              onRefresh: _onRefresh,
                              child: LayoutBuilder(builder:
                                  (BuildContext context,
                                      BoxConstraints constraints) {
                                return myPublicAppointments.isNotEmpty
                                    ? Container(
                                        width: sysWidth,
                                        height: constraints.maxHeight,
                                        child: SingleChildScrollView(
                                          child: Column(
                                            children: [
                                              for (var i = 0;
                                                  i <
                                                      myPublicAppointments
                                                          .length;
                                                  i++)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Column(
                                                    children: [
                                                      Slidable(
                                                        key: ValueKey(
                                                            'public_appt_${_publicAppointmentId(myPublicAppointments[i])}'),
                                                        endActionPane:
                                                            ActionPane(
                                                          motion:
                                                              BehindMotion(),
                                                          dismissible:
                                                              DismissiblePane(
                                                                  onDismissed:
                                                                      () {}),
                                                          children: [
                                                            SlidableAction(
                                                              onPressed: (ctx) {
                                                                print(
                                                                    "Delete Appointment");
                                                              },
                                                              backgroundColor:
                                                                  Color(
                                                                      0xff0c213a),
                                                              foregroundColor:
                                                                  Colors.white,
                                                              icon: Icons
                                                                  .delete_outline,
                                                              label: 'Delete',
                                                              autoClose: true,
                                                            ),
                                                          ],
                                                        ),
                                                        child: InkWell(
                                                          onTap: () {
                                                            print(
                                                                "Select Conplaint");
                                                            // Navigator.push(
                                                            //   context,
                                                            //   MaterialPageRoute(
                                                            //     builder: (context) =>
                                                            //         SingleSubmissionScreen(
                                                            //             "${myPublicAppointments[i]['CID']}",
                                                            //             "${myPublicAppointments[i]['NIC']}"),
                                                            //   ),
                                                            // );
                                                          },
                                                          child: Container(
                                                            width: sysWidth,
                                                            height:
                                                                _appointmentCardHeight,
                                                            decoration: BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            3),
                                                                border: Border.all(
                                                                    color: Colors
                                                                        .black45)),
                                                            child: Row(
                                                              children: [
                                                                _complaintStyleIdStrip(
                                                                  'AID-${_publicAppointmentId(myPublicAppointments[i])}',
                                                                ),
                                                                Expanded(
                                                                  flex: 14,
                                                                  child: Container(
                                                                    height: double.infinity,
                                                                    decoration: const BoxDecoration(
                                                                      border: Border(
                                                                        left: BorderSide(
                                                                            color: Colors.black45),
                                                                      ),
                                                                    ),
                                                                    child:
                                                                        SingleChildScrollView(
                                                                      child:
                                                                          Padding(
                                                                        padding: const EdgeInsets
                                                                            .only(
                                                                          left: 8,
                                                                          top: 5,
                                                                          bottom: 5,
                                                                        ),
                                                                        child:
                                                                            Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.center,
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
                                                                                  "${myPublicAppointments[i]['Type']}",
                                                                                  style: TextStyle(
                                                                                    fontSize: 15,
                                                                                    // fontWeight: FontWeight.bold,
                                                                                    color: textBlackColor,
                                                                                    fontFamily: 'Poppins-Light',
                                                                                  ),
                                                                                ),
                                                                              )
                                                                            ],
                                                                          ),
                                                                          Row(
                                                                            children: [
                                                                              Text(
                                                                                "Request Date & Time : ",
                                                                                style: TextStyle(
                                                                                  fontSize: 15,
                                                                                  fontWeight: FontWeight.bold,
                                                                                  color: textBlackColor,
                                                                                  fontFamily: 'Poppins-Bold',
                                                                                ),
                                                                              ),
                                                                              Column(
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                children: [
                                                                                  Text(
                                                                                    formatStoredDate(
                                                                                      myPublicAppointments[i]['RequestedDate'],
                                                                                      pattern: 'yyyy-MM-dd',
                                                                                    ),
                                                                                    style: TextStyle(
                                                                                      fontSize: 15,
                                                                                      // fontWeight: FontWeight.bold,
                                                                                      color: textBlackColor,
                                                                                      fontFamily: 'Poppins-Light',
                                                                                    ),
                                                                                  ),
                                                                                  Text(
                                                                                    formatStoredDate(
                                                                                      myPublicAppointments[i]['RequestedDate'],
                                                                                      pattern: 'hh:mm a',
                                                                                    ),
                                                                                    style: TextStyle(
                                                                                      fontSize: 15,
                                                                                      // fontWeight: FontWeight.bold,
                                                                                      color: textBlackColor,
                                                                                      fontFamily: 'Poppins-Light',
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ],
                                                                          ),
                                                                          Row(
                                                                            children: [
                                                                              Text(
                                                                                "Schedule Date : ",
                                                                                style: TextStyle(
                                                                                  fontSize: 15,
                                                                                  fontWeight: FontWeight.bold,
                                                                                  color: textBlackColor,
                                                                                  fontFamily: 'Poppins-Bold',
                                                                                ),
                                                                              ),
                                                                              Column(
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                children: [
                                                                                  Text(
                                                                                    "${myPublicAppointments[i]['ScheduledDate']}",
                                                                                    style: TextStyle(
                                                                                      fontSize: 15,
                                                                                      // fontWeight: FontWeight.bold,
                                                                                      color: textBlackColor,
                                                                                      fontFamily: 'Poppins-Light',
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ],
                                                                          ),
                                                                          Row(
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
                                                                              Text(
                                                                                "${myPublicAppointments[i]['Description']}",
                                                                                style: TextStyle(
                                                                                  fontSize: 15,
                                                                                  // fontWeight: FontWeight.bold,
                                                                                  color: textBlackColor,
                                                                                  fontFamily: 'Poppins-Light',
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      )
                                    : Container(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "No Appointment Submitted",
                                              style: TextStyle(
                                                fontSize: 15,
                                                color: textBlackColor,
                                                fontFamily: 'Poppins-Light',
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                              }),
                            ),
                          ),
                          Container(
                            child: LayoutBuilder(builder: (BuildContext context,
                                BoxConstraints constraints) {
                              return myPoliceAppointments.isNotEmpty
                                  ? Container(
                                      width: sysWidth,
                                      height: constraints.maxHeight,
                                      child: SingleChildScrollView(
                                        child: Column(
                                          children: [
                                            for (var i = 0;
                                                i < myPoliceAppointments.length;
                                                i++)
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Column(
                                                  children: [
                                                    Slidable(
                                                      key: ValueKey(
                                                          'police_appt_${_policeAppointmentId(myPoliceAppointments[i])}'),
                                                      endActionPane: ActionPane(
                                                        motion: BehindMotion(),
                                                        dismissible:
                                                            DismissiblePane(
                                                                onDismissed:
                                                                    () {}),
                                                        children: [
                                                          SlidableAction(
                                                            onPressed: (ctx) {
                                                              print(
                                                                  "Delete Appointment");
                                                            },
                                                            backgroundColor:
                                                                Color(
                                                                    0xff0c213a),
                                                            foregroundColor:
                                                                Colors.white,
                                                            icon: Icons
                                                                .delete_outline,
                                                            label: 'Delete',
                                                            autoClose: true,
                                                          ),
                                                        ],
                                                      ),
                                                      child: InkWell(
                                                        onTap: () {
                                                          // print(
                                                          //     "Select Complaint");
                                                          // Navigator.push(
                                                          //   context,
                                                          //   MaterialPageRoute(
                                                          //     builder: (context) =>
                                                          //         SingleSubmissionScreen(
                                                          //             "${myPublicAppointments[i]['CID']}",
                                                          //             "${myPublicAppointments[i]['NIC']}"),
                                                          //   ),
                                                          // );
                                                        },
                                                        child: Container(
                                                          width: sysWidth,
                                                          height:
                                                              _appointmentCardHeight,
                                                          decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          3),
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .black45)),
                                                          child: Row(
                                                            children: [
                                                              _complaintStyleIdStrip(
                                                                'AID-${_policeAppointmentId(myPoliceAppointments[i])}',
                                                              ),
                                                              Expanded(
                                                                flex: 14,
                                                                child: Container(
                                                                  height: double.infinity,
                                                                  decoration: const BoxDecoration(
                                                                    border: Border(
                                                                      left: BorderSide(
                                                                          color: Colors.black45),
                                                                    ),
                                                                  ),
                                                                  child:
                                                                      SingleChildScrollView(
                                                                    child: Padding(
                                                                      padding: const EdgeInsets
                                                                          .only(
                                                                        left: 8,
                                                                        top: 5,
                                                                        bottom: 5,
                                                                      ),
                                                                      child: Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment
                                                                                .start,
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment
                                                                                .center,
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
                                                                                "${myPoliceAppointments[i]['Type']}",
                                                                                style: TextStyle(
                                                                                  fontSize: 15,
                                                                                  // fontWeight: FontWeight.bold,
                                                                                  color: textBlackColor,
                                                                                  fontFamily: 'Poppins-Light',
                                                                                ),
                                                                              ),
                                                                            )
                                                                          ],
                                                                        ),
                                                                        Row(
                                                                          children: [
                                                                            Text(
                                                                              "Schedule Date : ",
                                                                              style: TextStyle(
                                                                                fontSize: 15,
                                                                                fontWeight: FontWeight.bold,
                                                                                color: textBlackColor,
                                                                                fontFamily: 'Poppins-Bold',
                                                                              ),
                                                                            ),
                                                                            Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                Text(
                                                                                  "${myPoliceAppointments[i]['ScheduledDate']}",
                                                                                  style: TextStyle(
                                                                                    fontSize: 15,
                                                                                    // fontWeight: FontWeight.bold,
                                                                                    color: textBlackColor,
                                                                                    fontFamily: 'Poppins-Light',
                                                                                  ),
                                                                                ),
                                                                              ],
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
                                                                                "${myPoliceAppointments[i]['City']}",
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
                                                              ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : Container(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "No Appointment",
                                            style: TextStyle(
                                              fontSize: 15,
                                              color: textBlackColor,
                                              fontFamily: 'Poppins-Light',
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                            }),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
