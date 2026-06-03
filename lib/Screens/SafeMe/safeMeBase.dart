import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:camera/camera.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:safe_me/service/firebase_service.dart';
import 'package:safe_me/service/userService.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:safe_me/util/date_parse_util.dart';
import '../../Controller/language_controller.dart';
import '../../Resources/colors.dart';
import '../../widgets/drawer.dart';
import '../home_base.dart';
import 'safeMeForm.dart';

class SafeMeBase extends StatefulWidget {
  const SafeMeBase({Key? key}) : super(key: key);

  @override
  _SafeMeBaseState createState() => _SafeMeBaseState();
}

class _SafeMeBaseState extends State<SafeMeBase> {
  late CameraController controller;
  final _imagePicker = ImagePicker();
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  List<Map<String, dynamic>> mySafeMeAlerts = [];

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

  Future<void> getSafeMeData() async {
    EasyLoading.show(status: "Getting SafeMe Data");
    try {
      final sessionOk = await UserService().checkSession();
      if (!sessionOk) {
        if (mounted) setState(() => mySafeMeAlerts = []);
        return;
      }

      final nic = await UserService().getLoggedInNic();
      if (nic == null || nic.isEmpty) {
        if (mounted) setState(() => mySafeMeAlerts = []);
        return;
      }

      final items =
          await FirebaseService.instance.fetchMySafeMeAlerts(nic);

      if (!mounted) return;
      setState(() {
        mySafeMeAlerts = items;
      });

      debugPrint(
          '************ My SafeMe (${nic}): ${mySafeMeAlerts.length} **************');
    } catch (e) {
      debugPrint('Failed to load SafeMe alerts: $e');
      if (mounted) setState(() => mySafeMeAlerts = []);
    } finally {
      EasyLoading.dismiss();
    }
  }

  getCamera() async {
    List<CameraDescription> cameras = await availableCameras();
    controller = CameraController(cameras[0], ResolutionPreset.medium);
  }

  void _onRefresh() async {
    await getSafeMeData();
    _refreshController.refreshCompleted();
  }

  Future<void> _confirmAndDeleteAlert(int index, {bool confirm = true}) async {
    if (index < 0 || index >= mySafeMeAlerts.length) return;
    final sid = '${mySafeMeAlerts[index]['SID']}';

    if (confirm) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Delete alert?'),
          content: Text('Remove SafeMe alert SID-$sid?'),
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

    final removed = mySafeMeAlerts[index];
    setState(() {
      mySafeMeAlerts.removeWhere((e) => '${e['SID']}' == sid);
    });

    EasyLoading.show(status: 'Deleting...');
    try {
      await FirebaseService.instance.deleteSafeMeAlert(sid);
    } catch (e) {
      debugPrint('Delete SafeMe failed: $e');
      if (mounted) {
        setState(() => mySafeMeAlerts.insert(index, removed));
      }
      EasyLoading.showError('Delete failed');
    } finally {
      EasyLoading.dismiss();
    }
  }

  @override
  void initState() {
    super.initState();
    getCamera();
    getSafeMeData();
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
          "Safe_Me".tr(),
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
      body: Container(
        width: sysWidth,
        height: sysHeight,
        child: Column(
          children: [
            Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    onTap: () async {
                      Alert(
                        context: context,
                        type: AlertType.warning,
                        title: "ALERT",
                        desc:
                            "Is this really an emergency? I agree to the privacy policies and terms and conditions.",
                        buttons: [
                          DialogButton(
                            child: Text(
                              "CANCEL",
                              style: TextStyle(color: Colors.white),
                            ),
                            onPressed: () => Navigator.pop(context),
                            color: secondary,
                          ),
                          DialogButton(
                            child: Text(
                              "Yes and Agree",
                              style: TextStyle(color: Colors.white),
                            ),
                            onPressed: () {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const SafeMeForm()));
                            },
                            color: secondary,
                          )
                        ],
                      ).show();
                    },
                    child: Container(
                      width: sysWidth,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(3),
                          //border: Border.all(width: 1,color: Colors.red),
                          boxShadow: const [
                            BoxShadow(
                              blurRadius: 1,
                              color: Colors.black45,
                            ),
                          ]),
                      child: Text(
                        "Safe Me",
                        style: TextStyle(
                            fontSize: 22,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins-Light'),
                      ),
                    ),
                  ),
                )),
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

                child: LayoutBuilder(builder:
                    (BuildContext context, BoxConstraints constraints) {
                  return mySafeMeAlerts.isNotEmpty
                      ? Container(
                          width: sysWidth,
                          height: constraints.maxHeight,
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                for (var i = 0; i < mySafeMeAlerts.length; i++)
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      children: [
                                        Slidable(
                                          key: ValueKey(
                                              'safeme_${mySafeMeAlerts[i]['SID']}'),
                                          endActionPane: ActionPane(
                                            motion: BehindMotion(),
                                            dismissible: DismissiblePane(
                                              onDismissed: () =>
                                                  _confirmAndDeleteAlert(
                                                i,
                                                confirm: false,
                                              ),
                                            ),
                                            children: [
                                              SlidableAction(
                                                onPressed: (ctx) =>
                                                    _confirmAndDeleteAlert(i),
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
                                              print("Select SafeMe");
                                              // Navigator.push(
                                              //   context,
                                              //   MaterialPageRoute(
                                              //     builder: (context) =>
                                              //         SingleSubmissionScreen(
                                              //             "${(complaintData.values.toList())[i]['CID']}",
                                              //             "${(complaintData.values.toList())[i]['NIC']}"),
                                              //   ),
                                              // );
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
                                                            "CID-${mySafeMeAlerts[i]['SID']}",
                                                            style: TextStyle(
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
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
                                                              color: Colors
                                                                  .black45),
                                                          right: BorderSide(
                                                              color: Colors
                                                                  .black45),
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
                                                                          5,
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
                                                                          "${mySafeMeAlerts[i]['Image1']}",
                                                                          "${mySafeMeAlerts[i]['Image2']}",
                                                                          "${mySafeMeAlerts[i]['Image3']}",
                                                                          "${mySafeMeAlerts[i]['Image4']}",
                                                                          "${mySafeMeAlerts[i]['Image5']}",
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
                                                                  indicators(5,
                                                                      activePage),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 10,
                                                    child:
                                                        SingleChildScrollView(
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
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
                                                                  "City : ",
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        15,
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
                                                                    "${mySafeMeAlerts[i]['City']}",
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
                                                                    fontSize:
                                                                        15,
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
                                                                  "${mySafeMeAlerts[i]['District']}",
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
                                                                )
                                                              ],
                                                            ),
                                                            Row(
                                                              children: [
                                                                Text(
                                                                  "Date & Time : ",
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        15,
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
                                                                        mySafeMeAlerts[i]['Date'],
                                                                        pattern: 'yyyy-MM-dd',
                                                                      ),
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            15,
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
                                                                    fontSize:
                                                                        15,
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
                                                                  "${mySafeMeAlerts[i]['Status']}",
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
                                "No SafeMe Submitted",
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
      ),
    );
  }
}
