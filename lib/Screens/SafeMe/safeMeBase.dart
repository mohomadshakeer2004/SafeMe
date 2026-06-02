import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:camera/camera.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
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

  Map<String, dynamic> safeMeData = {};

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

  getSafeMeData() async {
    String nic = "951240999V";
    EasyLoading.show(status: "Getting Complaint Data");
    final databaseRef = FirebaseDatabase.instance.ref();

    var get_UserData = databaseRef.child('/SafeMe/All');
    DatabaseEvent event = await get_UserData.once();

    Map<String, dynamic> data =
        jsonDecode(jsonEncode(event.snapshot.value)) as Map<String, dynamic>;
    setState(() {
      safeMeData = data;
    });

    print(
        "************ SafeMe Data = ${safeMeData.values.toList()}**************");
    EasyLoading.dismiss();
  }

  getCamera() async {
    List<CameraDescription> cameras = await availableCameras();
    controller = CameraController(cameras[0], ResolutionPreset.medium);
  }

  void _onRefresh() async {
    print("REFRESH STARTED");
    getSafeMeData();
    _refreshController.refreshCompleted();
    print("REFRESH STOPPED");
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
                  return safeMeData.length > 0
                      ? Container(
                          width: sysWidth,
                          height: constraints.maxHeight,
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                for (var i = 0; i < safeMeData.length; i++)
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      children: [
                                        Slidable(
                                          key: const ValueKey(0),
                                          endActionPane: ActionPane(
                                            motion: BehindMotion(),
                                            dismissible: DismissiblePane(
                                                onDismissed: () {}),
                                            children: [
                                              SlidableAction(
                                                onPressed: (ctx) {
                                                  print("Delete Complaint");
                                                },
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
                                                            "CID-${(safeMeData.values.toList())[i]['SID']}",
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
                                                                          "${(safeMeData.values.toList())[i]['Image1']}",
                                                                          "${(safeMeData.values.toList())[i]['Image2']}",
                                                                          "${(safeMeData.values.toList())[i]['Image3']}",
                                                                          "${(safeMeData.values.toList())[i]['Image4']}",
                                                                          "${(safeMeData.values.toList())[i]['Image5']}",
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
                                                                    "${(safeMeData.values.toList())[i]['City']}",
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
                                                                  "${(safeMeData.values.toList())[i]['District']}",
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
                                                                      DateFormat(
                                                                              'yyyy-MM-dd')
                                                                          .format(
                                                                              DateTime.parse(
                                                                        "${(safeMeData.values.toList())[i]['Date']}",
                                                                      )),
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
                                                                  "${(safeMeData.values.toList())[i]['Status']}",
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
