import 'dart:async';
import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:safe_me/data/police_stations.dart';
import 'package:safe_me/service/firebase_service.dart';
import 'package:safe_me/service/userService.dart';
import 'package:safe_me/util/user_data_util.dart';
import '../Screens/Complaint/complaint_base.dart';
import '../Screens/EmergencyContact/emergencyContact.dart';
import '../Screens/LostAndFound/lost_Found.dart';
import '../Screens/PoliceMap/policeMap.dart';
import '../Resources/colors.dart';
import '../widgets/drawer.dart';
import 'Appoinment/appointment_base.dart';
import 'package:safe_me/service/emergency_audio_service.dart';
import 'package:safe_me/service/home_shake_service.dart';
import 'package:safe_me/service/safeme_live_location_service.dart';
import 'package:safe_me/service/shake_voice_capture_service.dart';
import 'SafeMe/safeMeBase.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic> userData = {};
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
    speedAccuracy: 0,
  );

  bool _locationReady = false;
  List<NearestPoliceStation> _nearestStations = [];
  bool _shakeBusy = false;

  getUserData() async {
    final nic = await UserService().requireLoggedInNic();
    if (nic == null) return;
    final snapshot = await FirebaseService.instance.getPublicUser(nic);

    if (!snapshot.exists || snapshot.value == null) {
      EasyLoading.dismiss();
      return;
    }

    Map<String, dynamic> data = UserDataUtil.withDefaults(
      jsonDecode(jsonEncode(snapshot.value)) as Map<String, dynamic>,
      nic,
    );
    if (!mounted) return;
    setState(() {
      userData = data;
    });

    print("************ User Data = ${data}**************");
    print("************  User Email = ${data['Email']}**************");
    EasyLoading.dismiss();
  }

  getCurrLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }

      final positionCur = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (!mounted) return;
      setState(() {
        _position = positionCur;
        _locationReady = true;
        _nearestStations = PoliceStationsData.findNearest(
          positionCur.latitude,
          positionCur.longitude,
          count: 3,
        );
      });
    } catch (e) {
      debugPrint('Location unavailable: $e');
    } finally {
      EasyLoading.dismiss();
    }
  }

  @override
  void initState() {
    super.initState();
    getUserData();
    getCurrLocation();
    _bindShakeHandler();
    // Warm mic permission so shake can record immediately.
    unawaited(ShakeVoiceCaptureService.instance.ensureReady());
  }

  void _bindShakeHandler() {
    HomeShakeService.instance.onTripleShake = _onTripleShake;
  }

  void _onTripleShake() {
    // Always attempt send — do not require mounted (IndexedStack / overlays).
    if (_shakeBusy) {
      debugPrint('Shake ignored: already sending');
      return;
    }
    unawaited(_runShakeSafeMe());
  }

  Future<Position> _resolveShakePosition() async {
    // Prefer a quick fix; never hang the emergency send.
    try {
      final fresh = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 4),
        ),
      );
      return fresh;
    } catch (e) {
      debugPrint('Shake GPS timeout/fail: $e');
    }

    try {
      final last = await Geolocator.getLastKnownPosition();
      if (last != null) return last;
    } catch (e) {
      debugPrint('Shake last-known GPS failed: $e');
    }

    return _position;
  }

  Future<void> _runShakeSafeMe() async {
    if (_shakeBusy) return;
    _shakeBusy = true;

    print(
      '*************************ShakeDetector Start*****************************',
    );

    // Hard watchdog so a hung network/GPS call cannot block future shakes.
    final busyWatchdog = Timer(const Duration(seconds: 60), () {
      debugPrint('Shake busy watchdog fired — resetting');
      _shakeBusy = false;
    });

    try {
      EasyLoading.show(status: 'Sending emergency…');

      final sessionOk = await UserService()
          .checkSession()
          .timeout(const Duration(seconds: 8), onTimeout: () => false);
      if (!sessionOk) {
        EasyLoading.showError('Please log in again');
        return;
      }

      if (userData.isEmpty) {
        try {
          await getUserData().timeout(const Duration(seconds: 8));
        } catch (e) {
          debugPrint('Shake userData load failed: $e');
        }
      }

      final pos = await _resolveShakePosition();
      if (mounted) {
        setState(() {
          _position = pos;
          _locationReady =
              pos.latitude != 0 || pos.longitude != 0;
        });
      } else {
        _position = pos;
        _locationReady = pos.latitude != 0 || pos.longitude != 0;
      }

      final sid = await submitSafeMe(
        UserDataUtil.field(userData, 'Address'),
        DateTime.now(),
        UserDataUtil.field(userData, 'Email'),
        pos.latitude,
        pos.longitude,
        UserDataUtil.mobileAsInt(userData),
        UserDataUtil.field(userData, 'NIC'),
        UserDataUtil.field(userData, 'Name'),
        UserDataUtil.field(userData, 'ProfileImage'),
      ).timeout(
        const Duration(seconds: 40),
        onTimeout: () {
          debugPrint('shake submitSafeMe timed out');
          return null;
        },
      );

      if (sid == null) {
        EasyLoading.showError('Emergency send failed — try again');
        return;
      }

      // Live GPS for admin (non-blocking).
      unawaited(SafeMeLiveLocationService.instance.start(sid));

      // Voice capture after send — let alarm ring ~5s first, then mute for mic.
      unawaited(() async {
        try {
          await Future<void>.delayed(const Duration(seconds: 5));
          await EmergencyAudioService.instance.stopForMicCapture(
            settle: const Duration(milliseconds: 800),
          );
          final audio = await ShakeVoiceCaptureService.instance.recordFor(
            duration: const Duration(seconds: 12),
          );
          if (audio != null) {
            await ShakeVoiceCaptureService.instance.uploadForAlert(
              sid: sid,
              audioFile: audio,
            );
          }
        } catch (e) {
          debugPrint('Shake voice finalize failed: $e');
        }
      }());
    } catch (e, st) {
      debugPrint('Shake emergency failed: $e\n$st');
      EasyLoading.showError('Emergency send failed');
    } finally {
      busyWatchdog.cancel();
      _shakeBusy = false;
    }
  }

  @override
  void reassemble() {
    super.reassemble();
    _bindShakeHandler();
  }

  @override
  void dispose() {
    // Keep handler if HomeBase still owns the tab stack; HomeBase clears on exit.
    // Only clear if we are the current handler (avoid wiping a rebound handler).
    if (identical(HomeShakeService.instance.onTripleShake, _onTripleShake)) {
      HomeShakeService.instance.clearHandler();
    }
    super.dispose();
  }

  String get _userName {
    final name = UserDataUtil.field(userData, 'Name');
    if (name.isEmpty) return '';
    return name.split(' ').first;
  }

  void _openPoliceMap() {
    final hasLocation =
        _locationReady && _position.latitude != 0 && _position.longitude != 0;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PoliceMap(
          initialLatitude: hasLocation ? _position.latitude : null,
          initialLongitude: hasLocation ? _position.longitude : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sysWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: appSurface,
      drawer: Drawer(child: DrawerWidget()),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(sysWidth),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildEmergencyCard(),
                  const SizedBox(height: 16),
                  _buildLocationCard(),
                  const SizedBox(height: 22),
                  _buildSectionTitle('Citizen_Services'.tr()),
                  const SizedBox(height: 14),
                  _buildServicesGrid(sysWidth),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(double sysWidth) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            secondary,
            Color.lerp(secondary, const Color(0xFF061525), 0.4)!,
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: appAccent.withValues(alpha: 0.85),
            width: 3,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: secondary.withValues(alpha: 0.28),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 16, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Builder(
                    builder: (context) => IconButton(
                      icon: SvgPicture.asset(
                        'assets/icons/menu.svg',
                        height: 22,
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                      tooltip: MaterialLocalizations.of(
                        context,
                      ).openAppDrawerTooltip,
                    ),
                  ),
                  Container(
                    height: 46,
                    width: 46,
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.18),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.shield_rounded,
                        color: secondary,
                        size: 28,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SafeMe',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: normalTextColor,
                            fontFamily: 'Poppins-Bold',
                            letterSpacing: 0.4,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '119_Emergency'.tr(),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withValues(alpha: 0.72),
                            fontFamily: 'Poppins-Light',
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (_userName.isNotEmpty) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.14),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.verified_user_outlined,
                        size: 16,
                        color: appAccent.withValues(alpha: 0.95),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${'Hello'.tr().split('\n').first}, $_userName',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.92),
                          fontFamily: 'Poppins-Regular',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmergencyCard() {
    return Material(
      color: Colors.transparent,
      elevation: 0,
      borderRadius: BorderRadius.circular(_HomeUi.radius),
      child: InkWell(
        onTap: () {
          const number = '1119';
          FlutterPhoneDirectCaller.callNumber(number);
        },
        borderRadius: BorderRadius.circular(_HomeUi.radius),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [emergencyPrimary, emergencySecondary],
            ),
            borderRadius: BorderRadius.circular(_HomeUi.radius),
            boxShadow: [
              BoxShadow(
                color: emergencySecondary.withValues(alpha: 0.32),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: 12,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Icon(
                    Icons.local_police_rounded,
                    size: 110,
                    color: Colors.white.withValues(alpha: 0.07),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 18,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(13),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.22),
                        ),
                      ),
                      child: const Icon(
                        Icons.phone_in_talk_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '119',
                            style: TextStyle(
                              fontSize: 34,
                              color: Colors.white,
                              letterSpacing: 5,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'ARLRDBD',
                              height: 1,
                            ),
                          ),
                          Text(
                            'Emergency'.tr(),
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins-Bold',
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Call_119'.tr(),
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withValues(alpha: 0.88),
                              fontFamily: 'Poppins-Light',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const _RingingPhoneIcon(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationCard() {
    final hasLocation =
        _locationReady && _position.latitude != 0 && _position.longitude != 0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _openPoliceMap,
        borderRadius: BorderRadius.circular(_HomeUi.radius),
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: _HomeUi.cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                color: secondary.withValues(alpha: 0.04),
                child: Row(
                  children: [
                    _HomeUi.iconBadge(
                      icon: Icons.my_location_rounded,
                      color: secondary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your_Location'.tr(),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: secondary,
                              fontFamily: 'Poppins-Bold',
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            hasLocation
                                ? '${_position.latitude.toStringAsFixed(5)}, ${_position.longitude.toStringAsFixed(5)}'
                                : 'Locating'.tr(),
                            style: TextStyle(
                              fontSize: 11,
                              color: hasLocation ? appTextMuted : appTextSubtle,
                              fontFamily: 'Poppins-Light',
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: Icon(
                        Icons.refresh_rounded,
                        color: secondary.withValues(alpha: 0.65),
                        size: 20,
                      ),
                      onPressed: getCurrLocation,
                      tooltip: 'Refresh'.tr(),
                    ),
                    Icon(
                      Icons.map_outlined,
                      color: appAccent.withValues(alpha: 0.9),
                      size: 20,
                    ),
                  ],
                ),
              ),
              if (_nearestStations.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 3,
                            height: 14,
                            decoration: BoxDecoration(
                              color: appAccent,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Nearest_Police_Stations'.tr(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: secondary,
                              fontFamily: 'Poppins-Bold',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ...List.generate(_nearestStations.length, (index) {
                        final station = _nearestStations[index];
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: index == _nearestStations.length - 1
                                ? 0
                                : 8,
                          ),
                          child: _HomeUi.stationRow(
                            rank: index + 1,
                            title: station.displayName(index + 1),
                            distance: station.distanceLabel,
                          ),
                        );
                      }),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [secondary, appAccent],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: secondary,
            fontFamily: 'Poppins-Bold',
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildServicesGrid(double sysWidth) {
    final tileWidth = (sysWidth - 32 - 12) / 2;

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _ServiceTile(
          width: tileWidth,
          label: 'Complaint'.tr(),
          iconPath: 'assets/icons/complaint.png',
          accentColor: secondary,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ComplaintHome()),
          ),
        ),
        _ServiceTile(
          width: tileWidth,
          label: 'Safe_Me'.tr(),
          iconPath: 'assets/icons/safe.png',
          accentColor: emergencyPrimary,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SafeMeBase()),
          ),
        ),
        _ServiceTile(
          width: tileWidth,
          label: 'Appointment'.tr(),
          iconPath: 'assets/icons/appointment.png',
          accentColor: secondary,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AppointmentBase()),
          ),
        ),
        _ServiceTile(
          width: tileWidth,
          label: 'Police_Map'.tr(),
          iconPath: 'assets/icons/nearest.png',
          accentColor: appAccent,
          onTap: _openPoliceMap,
        ),
        _ServiceTile(
          width: tileWidth,
          label: 'Lost_Found'.tr(),
          iconPath: 'assets/icons/lost_found.png',
          accentColor: secondary,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LostFoundItem()),
          ),
        ),
        _ServiceTile(
          width: tileWidth,
          label: 'Contact'.tr(),
          iconPath: 'assets/icons/contact.png',
          accentColor: secondary,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EmergencyContact()),
          ),
        ),
      ],
    );
  }

  Future<int?> submitSafeMe(
    String Address,
    DateTime Date,
    String Email,
    double Latitude,
    double Longitude,
    int Mobile,
    String NIC,
    String Name,
    String ProfileImage,
  ) async {
    EasyLoading.show(status: "Submitting...");
    try {
      final firebase = FirebaseService.instance;
      final sid = await firebase.allocateNextSafeMeId();
      print('shake submitSafeMe: SID=$sid');

      final data = {
        'SID': sid,
        'Address': Address,
        'AudioMP3': '',
        'City': UserDataUtil.field(userData, 'City'),
        'Date': Date.toString(),
        'District': UserDataUtil.field(userData, 'District'),
        'Email': Email,
        'Image1': '',
        'Image2': '',
        'Image3': '',
        'Image4': '',
        'Image5': '',
        'Latitude': Latitude,
        'Longitude': Longitude,
        'LiveLocation': true,
        'LocationUpdatedAt': DateTime.now().toIso8601String(),
        'LiveTick': DateTime.now().millisecondsSinceEpoch,
        'Mobile': Mobile,
        'NIC': UserDataUtil.normalizeNic(NIC),
        'Name': Name,
        'ProfileImage': ProfileImage,
        'Severity': 'High',
        'Status': 'Alert Sent',
        'Source': 'Shake Emergency',
      };

      await firebase.saveSafeMeAlert(sid: sid, data: data);
      await firebase.syncSafeMeCounters(sid);

      EasyLoading.showSuccess(
        'Emergency sent — voice + live location sharing…',
      );
      return sid;
    } catch (e) {
      print('shake submitSafeMe failed: $e');
      EasyLoading.showError('SafeMe alert failed');
      return null;
    } finally {
      EasyLoading.dismiss();
    }
  }
}

/// White ringing phone icon for the emergency card (always visible on red).
class _RingingPhoneIcon extends StatefulWidget {
  const _RingingPhoneIcon();

  @override
  State<_RingingPhoneIcon> createState() => _RingingPhoneIconState();
}

class _RingingPhoneIconState extends State<_RingingPhoneIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _shake;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
    _shake = Tween<double>(
      begin: -0.12,
      end: 0.12,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shake,
      builder: (context, child) {
        return Transform.rotate(angle: _shake.value, child: child);
      },
      child: const Icon(
        Icons.ring_volume_rounded,
        color: Colors.white,
        size: 32,
      ),
    );
  }
}

class _HomeUi {
  static const double radius = 16;

  static BoxDecoration cardDecoration() {
    return BoxDecoration(
      color: appSurfaceElevated,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: appBorder),
      boxShadow: [
        BoxShadow(
          color: secondary.withValues(alpha: 0.06),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  static Widget iconBadge({required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.12)),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  static Widget stationRow({
    required int rank,
    required String title,
    required String distance,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: appSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: appBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [secondary, Color.lerp(secondary, appAccent, 0.35)!],
              ),
              shape: BoxShape.circle,
            ),
            child: Text(
              '$rank',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins-Bold',
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: secondary,
                fontFamily: 'Poppins-Bold',
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: appAccent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              distance,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: secondary,
                fontFamily: 'Poppins-Bold',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceTile extends StatelessWidget {
  const _ServiceTile({
    required this.width,
    required this.label,
    required this.iconPath,
    required this.onTap,
    required this.accentColor,
  });

  final double width;
  final String label;
  final String iconPath;
  final VoidCallback onTap;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(_HomeUi.radius),
          child: Ink(
            decoration: BoxDecoration(
              color: appSurfaceElevated,
              borderRadius: BorderRadius.circular(_HomeUi.radius),
              border: Border.all(color: appBorder),
              boxShadow: [
                BoxShadow(
                  color: secondary.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(_HomeUi.radius),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 18,
                    horizontal: 12,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(13),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.09),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: accentColor.withValues(alpha: 0.14),
                          ),
                        ),
                        child: Image.asset(
                          iconPath,
                          height: 26,
                          color: accentColor,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.apps_rounded,
                            color: accentColor,
                            size: 26,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        label,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: secondary,
                          fontFamily: 'Poppins-Bold',
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
