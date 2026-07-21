import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:safe_me/service/firebase_service.dart';
import 'package:safe_me/service/userService.dart';
import 'package:safe_me/util/date_parse_util.dart';
import 'package:safe_me/util/user_data_util.dart';

import '../../Controller/language_controller.dart';
import '../../Resources/colors.dart';
import '../../widgets/drawer.dart';
import '../Complaint/complaint_ui.dart';
import '../home_base.dart';
import 'appoinmentForm.dart';

class AppointmentBase extends StatefulWidget {
  const AppointmentBase({Key? key}) : super(key: key);

  @override
  _AppointmentBaseState createState() => _AppointmentBaseState();
}

class _AppointmentBaseState extends State<AppointmentBase> {
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  List<Map<String, dynamic>> myPublicAppointments = [];
  List<Map<String, dynamic>> myPoliceAppointments = [];

  String _publicAppointmentId(Map<String, dynamic> item) =>
      '${item['AID'] ?? item['aid'] ?? ''}';

  String _policeAppointmentId(Map<String, dynamic> item) =>
      '${item['AIDP'] ?? item['AID'] ?? item['aid'] ?? ''}';

  String _appointmentStatus(Map<String, dynamic> item) {
    final raw = '${item['Status'] ?? ''}'.trim();
    if (raw.isNotEmpty) return raw;
    return 'Active';
  }

  bool _canRequestCancel(Map<String, dynamic> item) {
    final status = _appointmentStatus(item).toLowerCase();
    return status != 'cancel requested' && status != 'cancelled';
  }

  Future<void> _loadAppointments() async {
    EasyLoading.show(status: 'Getting_Appointment_Data'.tr());
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

  Future<void> _confirmCancelRequest(int index) async {
    if (index < 0 || index >= myPublicAppointments.length) return;
    final item = myPublicAppointments[index];
    final aid = _publicAppointmentId(item);

    if (!_canRequestCancel(item)) {
      EasyLoading.showInfo('Already_Cancel_Requested'.tr());
      return;
    }

    final fine = FirebaseService.appointmentCancelFine;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: appSurfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Cancel_Appointment_Title'.tr(),
          style: TextStyle(
            color: secondary,
            fontFamily: 'Poppins-Bold',
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Cancel_Appointment_Message'.tr(namedArgs: {
            'amount': fine.toStringAsFixed(0),
          }),
          style: TextStyle(
            color: appTextMuted,
            fontFamily: 'Poppins-Light',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel'.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Request_Cancel'.tr(),
              style: TextStyle(color: emergencyPrimary),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    EasyLoading.show(status: 'Submitting'.tr());
    try {
      await FirebaseService.instance.requestPublicAppointmentCancellation(aid);
      if (!mounted) return;
      setState(() {
        myPublicAppointments[index] = {
          ...item,
          'Status': 'Cancel Requested',
          'CancelFineAmount': fine,
          'CancelRequestedDate': DateTime.now().toIso8601String(),
        };
      });
      EasyLoading.showSuccess('Cancel_Request_Sent'.tr());
    } catch (e) {
      debugPrint('Cancel request failed: $e');
      EasyLoading.showError('Cancel_Request_Failed'.tr());
    } finally {
      EasyLoading.dismiss();
    }
  }

  Widget _idStrip(String label) {
    return Container(
      width: 44,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            secondary,
            Color.lerp(secondary, appAccent, 0.3)!,
          ],
        ),
      ),
      child: Center(
        child: RotatedBox(
          quarterTurns: 3,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Poppins-Bold',
            ),
          ),
        ),
      ),
    );
  }

  Widget _statusChip(String status) {
    final normalized = status.toLowerCase();
    Color bg;
    Color fg;

    if (normalized.contains('cancel requested')) {
      bg = const Color(0xFFFFEBEE);
      fg = emergencyPrimary;
    } else if (normalized.contains('cancelled')) {
      bg = secondary.withValues(alpha: 0.1);
      fg = appTextMuted;
    } else if (normalized.contains('pending')) {
      bg = const Color(0xFFFFF3E0);
      fg = const Color(0xFFE65100);
    } else {
      bg = appAccent.withValues(alpha: 0.15);
      fg = secondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: fg,
          fontFamily: 'Poppins-Bold',
        ),
      ),
    );
  }

  Widget _buildPublicCard(Map<String, dynamic> item, int index) {
    final status = _appointmentStatus(item);
    final fine = item['CancelFineAmount'];

    final card = Container(
      clipBehavior: Clip.antiAlias,
      decoration: ComplaintUi.cardDecoration(),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _idStrip('AID-${_publicAppointmentId(item)}'),
            Expanded(
              child: Container(
                color: appSurface,
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${item['Type'] ?? ''}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: secondary,
                              fontFamily: 'Poppins-Bold',
                            ),
                          ),
                        ),
                        _statusChip(status),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ComplaintUi.detailRow(
                      'RequestDateTime'.tr(),
                      '${formatStoredDate(item['RequestedDate'], pattern: 'yyyy-MM-dd')} '
                      '${formatStoredDate(item['RequestedDate'], pattern: 'hh:mm a')}',
                    ),
                    ComplaintUi.detailRow(
                      'Schedule_Date'.tr(),
                      '${item['ScheduledDate'] ?? '-'}',
                    ),
                    if (item['Description'] != null &&
                        '${item['Description']}'.isNotEmpty)
                      ComplaintUi.detailRow(
                        'Description'.tr(),
                        '${item['Description']}',
                      ),
                    if (status.toLowerCase() == 'cancel requested' &&
                        fine != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Cancel_Fine_Notice'.tr(namedArgs: {
                            'amount': '${fine is num ? fine.toStringAsFixed(0) : fine}',
                          }),
                          style: TextStyle(
                            fontSize: 12,
                            color: emergencyPrimary,
                            fontFamily: 'Poppins-Light',
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (!_canRequestCancel(item)) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: card,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Slidable(
        key: ValueKey('public_appt_${_publicAppointmentId(item)}'),
        endActionPane: ActionPane(
          motion: const BehindMotion(),
          extentRatio: 0.32,
          children: [
            SlidableAction(
              onPressed: (_) => _confirmCancelRequest(index),
              backgroundColor: emergencyPrimary,
              foregroundColor: Colors.white,
              icon: Icons.event_busy_outlined,
              label: 'Request_Cancel'.tr(),
              autoClose: true,
            ),
          ],
        ),
        child: card,
      ),
    );
  }

  Widget _buildPoliceCard(Map<String, dynamic> item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: ComplaintUi.cardDecoration(),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _idStrip('AID-${_policeAppointmentId(item)}'),
              Expanded(
                child: Container(
                  color: appSurface,
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${item['Type'] ?? ''}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: secondary,
                                fontFamily: 'Poppins-Bold',
                              ),
                            ),
                          ),
                          _statusChip('Police_Assigned'.tr()),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ComplaintUi.detailRow(
                        'AppointmentType'.tr(),
                        '${item['Type'] ?? '-'}',
                      ),
                      ComplaintUi.detailRow(
                        'Schedule_Date'.tr(),
                        '${item['ScheduledDate'] ?? '-'}',
                      ),
                      ComplaintUi.detailRow(
                        'City'.tr(),
                        '${item['City'] ?? '-'}',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<LanguageController>();
    final sysWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: appSurface,
      appBar: ComplaintUi.appBar(
        context: context,
        title: 'MyAppointment'.tr(),
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
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: ComplaintUi.primaryButton(
              label: 'Place_Appointment'.tr(),
              icon: Icons.add_circle_outline_rounded,
              width: double.infinity,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AppointmentForm(),
                  ),
                ).then((_) {
                  if (mounted) _loadAppointments();
                });
              },
            ),
          ),
          Expanded(
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  TabBar(
                    indicatorColor: appAccent,
                    labelColor: secondary,
                    unselectedLabelColor: appTextMuted,
                    labelStyle: const TextStyle(
                      fontFamily: 'Poppins-Bold',
                      fontWeight: FontWeight.w600,
                    ),
                    tabs: [
                      Tab(text: 'Appointment_History'.tr()),
                      Tab(text: 'Police_Appointments'.tr()),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        SmartRefresher(
                          enablePullDown: true,
                          header: WaterDropMaterialHeader(
                            backgroundColor: secondary,
                            color: appSurfaceElevated,
                          ),
                          controller: _refreshController,
                          onRefresh: _onRefresh,
                          child: myPublicAppointments.isNotEmpty
                              ? ListView.builder(
                                  padding: const EdgeInsets.only(top: 8, bottom: 16),
                                  itemCount: myPublicAppointments.length,
                                  itemBuilder: (context, i) =>
                                      _buildPublicCard(
                                    myPublicAppointments[i],
                                    i,
                                  ),
                                )
                              : ComplaintUi.emptyState(
                                  message: 'No_Appointment_Submitted'.tr(),
                                ),
                        ),
                        myPoliceAppointments.isNotEmpty
                            ? ListView.builder(
                                padding: const EdgeInsets.only(top: 8, bottom: 16),
                                itemCount: myPoliceAppointments.length,
                                itemBuilder: (context, i) =>
                                    _buildPoliceCard(myPoliceAppointments[i]),
                              )
                            : ComplaintUi.emptyState(
                                message: 'No_Police_Appointment'.tr(),
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
