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
import 'complaint_ui.dart';
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
    final item = myComplaints[index];
    final cid = '${item['CID']}';
    final status = '${item['Status'] ?? ''}'.trim().toLowerCase();

    if (status != 'delete approved') {
      EasyLoading.showInfo(
        'Police must approve delete first. Use Request Delete.',
      );
      return;
    }

    if (confirm) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Delete complaint?'),
          content: Text(
            'Police approved removal of complaint CID-$cid. Delete now?',
          ),
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
      await FirebaseService.instance.deleteComplaint(
        cid,
        nic: '${removed['NIC'] ?? ''}',
      );
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

  bool _canRequestComplaintDelete(Map<String, dynamic> item) {
    final status = '${item['Status'] ?? ''}'.trim().toLowerCase();
    return status != 'delete requested' && status != 'delete approved';
  }

  bool _canDeleteComplaint(Map<String, dynamic> item) {
    return '${item['Status'] ?? ''}'.trim().toLowerCase() == 'delete approved';
  }

  Future<void> _confirmRequestComplaintDelete(int index) async {
    if (index < 0 || index >= myComplaints.length) return;
    final item = myComplaints[index];
    final cid = '${item['CID']}';

    if (!_canRequestComplaintDelete(item)) {
      EasyLoading.showInfo('Delete already requested or approved');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Request delete?'),
        content: Text(
          'Complaint CID-$cid cannot be deleted until police approve. '
          'Send a delete request?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Request Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    EasyLoading.show(status: 'Submitting...');
    try {
      await FirebaseService.instance.requestComplaintDeletion(cid);
      if (!mounted) return;
      setState(() {
        myComplaints[index] = {
          ...item,
          'Status': 'Delete Requested',
          'DeleteRequestedDate': DateTime.now().toIso8601String(),
        };
      });
      EasyLoading.showSuccess('Delete request sent to police');
    } catch (e) {
      debugPrint('Complaint delete request failed: $e');
      EasyLoading.showError('Request failed');
    } finally {
      EasyLoading.dismiss();
    }
  }

  List<Widget> indicators(imagesLength, currentIndex) {
    return ComplaintUi.pageIndicators(imagesLength, currentIndex);
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
      backgroundColor: appSurface,
      appBar: ComplaintUi.appBar(
        context: context,
        title: 'Complaint'.tr(),
        sysWidth: sysWidth,
        onBack: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeBase()),
          );
        },
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
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: ComplaintUi.primaryButton(
                label: 'PlaceComplaint'.tr(),
                icon: Icons.add_circle_outline_rounded,
                width: double.infinity,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ComplaintForm()),
                  );
                },
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
                color: appSurfaceElevated,
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
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  child: Column(
                                    children: [
                                      Slidable(
                                        key: ValueKey(
                                            'complaint_${myComplaints[i]['CID']}'),
                                        endActionPane: _canDeleteComplaint(
                                                myComplaints[i])
                                            ? ActionPane(
                                                motion: BehindMotion(),
                                                children: [
                                                  SlidableAction(
                                                    onPressed: (ctx) =>
                                                        _confirmAndDeleteComplaint(
                                                            i),
                                                    backgroundColor:
                                                        Color(0xff0c213a),
                                                    foregroundColor:
                                                        Colors.white,
                                                    icon: Icons.delete_outline,
                                                    label: 'Delete',
                                                    autoClose: true,
                                                  ),
                                                ],
                                              )
                                            : _canRequestComplaintDelete(
                                                    myComplaints[i])
                                                ? ActionPane(
                                                    motion: BehindMotion(),
                                                    extentRatio: 0.38,
                                                    children: [
                                                      SlidableAction(
                                                        onPressed: (ctx) =>
                                                            _confirmRequestComplaintDelete(
                                                                i),
                                                        backgroundColor:
                                                            emergencyPrimary,
                                                        foregroundColor:
                                                            Colors.white,
                                                        icon: Icons
                                                            .hourglass_top_outlined,
                                                        label: 'Request Delete',
                                                        autoClose: true,
                                                      ),
                                                    ],
                                                  )
                                                : null,
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
                                            clipBehavior: Clip.antiAlias,
                                            decoration:
                                                ComplaintUi.cardDecoration(),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  flex: 1,
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        begin:
                                                            Alignment.topCenter,
                                                        end: Alignment
                                                            .bottomCenter,
                                                        colors: [
                                                          secondary,
                                                          Color.lerp(secondary,
                                                              appAccent, 0.3)!,
                                                        ],
                                                      ),
                                                    ),
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
                                                    decoration: BoxDecoration(
                                                      color: appSurface,
                                                      border: Border(
                                                        left: BorderSide(
                                                          color: appBorder,
                                                        ),
                                                        right: BorderSide(
                                                          color: appBorder,
                                                        ),
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
                                                              left: 12,
                                                              top: 8,
                                                              bottom: 8,
                                                              right: 8),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          _complaintInfoRow(
                                                            'Type',
                                                            '${myComplaints[i]['Type']}',
                                                          ),
                                                          _complaintInfoRow(
                                                            'District',
                                                            '${myComplaints[i]['District']}',
                                                          ),
                                                          _complaintInfoRow(
                                                            'City',
                                                            '${myComplaints[i]['City']}',
                                                          ),
                                                          Row(
                                                            children: [
                                                              Text(
                                                                'Date & Time : ',
                                                                style: TextStyle(
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  color:
                                                                      secondary,
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
                                                                      myComplaints[i]
                                                                          [
                                                                          'Date'],
                                                                      pattern:
                                                                          'yyyy-MM-dd',
                                                                    ),
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          12,
                                                                      color:
                                                                          appTextMuted,
                                                                      fontFamily:
                                                                          'Poppins-Light',
                                                                    ),
                                                                  ),
                                                                  Text(
                                                                    formatStoredDate(
                                                                      myComplaints[i]
                                                                          [
                                                                          'Date'],
                                                                      pattern:
                                                                          'hh:mm a',
                                                                    ),
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          12,
                                                                      color:
                                                                          appTextMuted,
                                                                      fontFamily:
                                                                          'Poppins-Light',
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                              height: 6),
                                                          Row(
                                                            children: [
                                                              Text(
                                                                'Status : ',
                                                                style: TextStyle(
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  color:
                                                                      secondary,
                                                                  fontFamily:
                                                                      'Poppins-Bold',
                                                                ),
                                                              ),
                                                              ComplaintUi
                                                                  .statusChip(
                                                                '${myComplaints[i]['Status']}',
                                                              ),
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
                    : ComplaintUi.emptyState(
                        message: 'No Complaints Submitted',
                      );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _complaintInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(
            '$label : ',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: secondary,
              fontFamily: 'Poppins-Bold',
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                color: appTextMuted,
                fontFamily: 'Poppins-Light',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
