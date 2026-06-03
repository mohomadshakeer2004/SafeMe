import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:safe_me/service/firebase_service.dart';
import 'package:safe_me/service/userService.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../Resources/colors.dart';
import '../../Resources/style.dart';
import '../../widgets/drawer.dart';
import '../home_base.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:safe_me/util/date_parse_util.dart';
import '../../Controller/language_controller.dart';
import 'complaintForm.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'singleSubmission.dart';

class ComplaintHome extends StatefulWidget {
  const ComplaintHome({Key? key}) : super(key: key);

  @override
  _ComplaintHomeState createState() => _ComplaintHomeState();
}

class _ComplaintHomeState extends State<ComplaintHome> {
  List<String> _submission = []; // ['1', '2', '2'];

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  List<Map<String, dynamic>> myComplaints = [];

  getComplaintData() async {
    EasyLoading.show(status: "Getting Complaint Data");
    try {
      final sessionOk = await UserService().checkSession();
      if (!sessionOk) {
        debugPrint('Complaints: not logged in');
        if (mounted) setState(() => myComplaints = []);
        return;
      }

      final nic = await UserService().getLoggedInNic();
      if (nic == null || nic.isEmpty) {
        if (mounted) setState(() => myComplaints = []);
        return;
      }

      final items =
          await FirebaseService.instance.fetchMyComplaints(nic);

      if (!mounted) return;
      setState(() {
        myComplaints = items;
      });

      debugPrint(
          '************ My complaints (${nic}): ${myComplaints.length} **************');
    } catch (e) {
      debugPrint('Failed to load complaints: $e');
      if (mounted) {
        setState(() {
          myComplaints = [];
        });
      }
    } finally {
      EasyLoading.dismiss();
    }
  }

  void _onRefresh() async {
    await getComplaintData();
    _refreshController.refreshCompleted();
  }

  Future<void> _confirmAndDeleteComplaint(int index, {bool confirm = true}) async {
    if (index < 0 || index >= myComplaints.length) return;
    final cid = '${myComplaints[index]['CID']}';

    if (confirm) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Delete complaint?'),
          content: Text('Remove complaint CID-$cid?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete'),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted) return;
    }

    final removed = myComplaints[index];
    setState(() {
      myComplaints.removeWhere((e) => '${e['CID']}' == cid);
    });

    EasyLoading.show(status: 'Deleting...');
    try {
      await FirebaseService.instance.deleteComplaint(cid);
    } catch (e) {
      debugPrint('Delete complaint failed: $e');
      if (mounted) {
        setState(() => myComplaints.insert(index, removed));
      }
      EasyLoading.showError('Delete failed');
    } finally {
      EasyLoading.dismiss();
    }
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
  PageController _pageController =
      PageController(viewportFraction: 1, initialPage: 0);

  @override
  void initState() {
    super.initState();
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
          "Complaint".tr(),
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
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: InkWell(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => ComplaintForm()));
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
                          "PlaceComplaint".tr(),
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
            child: SmartRefresher(
              enablePullDown: true,
              enablePullUp: true,
              header: WaterDropMaterialHeader(
                backgroundColor: secondary,
                color: mainBGColor,
              ),
              controller: _refreshController,
              onRefresh: _onRefresh,
              // child: ListView.builder(
              //   itemBuilder: (c, i) => Card(child: Center(child: Text(_submission[i]))),
              //   itemExtent: 100.0,
              //   itemCount: _submission.length,
              // ),

              child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                return myComplaints.isNotEmpty
                    ? Container(
                        width: sysWidth,
                        height: constraints.maxHeight,
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              for (var i = 0; i < myComplaints.length; i++)
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      Slidable(
                                        key: ValueKey(
                                            'complaint_${myComplaints[i]['CID']}'),
                                        endActionPane: ActionPane(
                                          motion: BehindMotion(),
                                          dismissible: DismissiblePane(
                                            onDismissed: () =>
                                                _confirmAndDeleteComplaint(
                                              i,
                                              confirm: false,
                                            ),
                                          ),
                                          children: [
                                            SlidableAction(
                                              onPressed: (ctx) =>
                                                  _confirmAndDeleteComplaint(i),
                                              backgroundColor:
                                                  Color(0xff0c213a),
                                              foregroundColor: Colors.white,
                                              icon: Icons.delete_outline,
                                              label: 'Delete',
                                              autoClose: true,
                                            ),
                                          ],
                                        ),
                                        child: InkWell(
                                          onTap: () {
                                            print("Select Conplaint");
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    SingleSubmissionScreen(
                                                        "${myComplaints[i]['CID']}",
                                                        "${myComplaints[i]['NIC']}"),
                                              ),
                                            );
                                          },
                                          child: Container(
                                            width: sysWidth,
                                            height: sysHeight * 0.2,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(3),
                                                border: Border.all(
                                                    color: Colors.black45)),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  flex: 1,
                                                  child: Container(
                                                    color: secondary,
                                                    height: double.infinity,
                                                    child: Center(
                                                      child: RotatedBox(
                                                        quarterTurns: 3,
                                                        child: Text(
                                                          "CID-${myComplaints[i]['CID']}",
                                                          style: TextStyle(
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                normalTextColor,
                                                            fontFamily:
                                                                'Poppins-Bold',
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 4,
                                                  child: Container(
                                                    // color: Colors.greenAccent,
                                                    height: double.infinity,
                                                    width: double.infinity,
                                                    decoration:
                                                        const BoxDecoration(
                                                      border: Border(
                                                        left: BorderSide(
                                                            color:
                                                                Colors.black45),
                                                        right: BorderSide(
                                                            color:
                                                                Colors.black45),
                                                      ),
                                                    ),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        Expanded(
                                                          flex: 8,
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: PageView
                                                                .builder(
                                                                    itemCount:
                                                                        2,
                                                                    pageSnapping:
                                                                        true,
                                                                    controller:
                                                                        _pageController,
                                                                    onPageChanged:
                                                                        (page) {
                                                                      setState(
                                                                          () {
                                                                        activePage =
                                                                            page;
                                                                      });
                                                                    },
                                                                    itemBuilder:
                                                                        (context,
                                                                            pagePosition) {
                                                                      var images =
                                                                          [
                                                                        "${myComplaints[i]['Image1']}",
                                                                        "${myComplaints[i]['Image2']}",
                                                                      ];
                                                                      return Container(
                                                                        child: images.isNotEmpty
                                                                            ? CachedNetworkImage(
                                                                                imageUrl: images[pagePosition],
                                                                                placeholder: (context, url) => Container(
                                                                                  width: 20,
                                                                                  height: 20,
                                                                                  child: const Center(
                                                                                    child: CircularProgressIndicator(),
                                                                                  ),
                                                                                ),
                                                                                errorWidget: (context, url, error) => Icon(Icons.error),
                                                                              )
                                                                            : Container(
                                                                                width: 20,
                                                                                height: 20,
                                                                                child: const Center(
                                                                                  child: CircularProgressIndicator(),
                                                                                ),
                                                                              ),
                                                                      );
                                                                    }),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          flex: 1,
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children:
                                                                indicators(2,
                                                                    activePage),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 10,
                                                  child: SingleChildScrollView(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 8,
                                                              top: 5,
                                                              bottom: 5),
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
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 15,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color:
                                                                      textBlackColor,
                                                                  fontFamily:
                                                                      'Poppins-Bold',
                                                                ),
                                                              ),
                                                              Flexible(
                                                                child: Text(
                                                                  "${myComplaints[i]['Type']}",
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        15,
                                                                    // fontWeight: FontWeight.bold,
                                                                    color:
                                                                        textBlackColor,
                                                                    fontFamily:
                                                                        'Poppins-Light',
                                                                  ),
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                          Row(
                                                            children: [
                                                              Text(
                                                                "District : ",
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 15,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color:
                                                                      textBlackColor,
                                                                  fontFamily:
                                                                      'Poppins-Bold',
                                                                ),
                                                              ),
                                                              Text(
                                                                "${myComplaints[i]['District']}",
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 15,
                                                                  // fontWeight: FontWeight.bold,
                                                                  color:
                                                                      textBlackColor,
                                                                  fontFamily:
                                                                      'Poppins-Light',
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                          Row(
                                                            children: [
                                                              Text(
                                                                "City : ",
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 15,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color:
                                                                      textBlackColor,
                                                                  fontFamily:
                                                                      'Poppins-Bold',
                                                                ),
                                                              ),
                                                              Text(
                                                                "${myComplaints[i]['City']}",
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 15,
                                                                  // fontWeight: FontWeight.bold,
                                                                  color:
                                                                      textBlackColor,
                                                                  fontFamily:
                                                                      'Poppins-Light',
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                          Row(
                                                            children: [
                                                              Text(
                                                                "Date & Time : ",
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 15,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color:
                                                                      textBlackColor,
                                                                  fontFamily:
                                                                      'Poppins-Bold',
                                                                ),
                                                              ),
                                                              Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Text(
                                                                    formatStoredDate(
                                                                      myComplaints[i]['Date'],
                                                                      pattern: 'yyyy-MM-dd',
                                                                    ),
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          15,
                                                                      // fontWeight: FontWeight.bold,
                                                                      color:
                                                                          textBlackColor,
                                                                      fontFamily:
                                                                          'Poppins-Light',
                                                                    ),
                                                                  ),
                                                                  Text(
                                                                    formatStoredDate(
                                                                      myComplaints[i]['Date'],
                                                                      pattern: 'hh:mm a',
                                                                    ),
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          15,
                                                                      // fontWeight: FontWeight.bold,
                                                                      color:
                                                                          textBlackColor,
                                                                      fontFamily:
                                                                          'Poppins-Light',
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                          Row(
                                                            children: [
                                                              Text(
                                                                "Status : ",
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 15,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color:
                                                                      textBlackColor,
                                                                  fontFamily:
                                                                      'Poppins-Bold',
                                                                ),
                                                              ),
                                                              Text(
                                                                "${myComplaints[i]['Status']}",
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 15,
                                                                  // fontWeight: FontWeight.bold,
                                                                  color:
                                                                      textBlackColor,
                                                                  fontFamily:
                                                                      'Poppins-Light',
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        ],
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
                                )
                            ],
                          ),
                        ),
                      )
                    : Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "No Complaints Submitted",
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
        ],
      ),
    );
  }
}
