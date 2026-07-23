import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:safe_me/service/firebase_service.dart';
import 'package:safe_me/service/storage_service.dart';
import 'package:safe_me/service/userService.dart';
import 'package:safe_me/util/user_data_util.dart';

import '../Controller/language_controller.dart';
import '../Resources/colors.dart';
import '../widgets/changePasswordAlert.dart';
import '../widgets/drawer.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _txtFNameController = TextEditingController();
  final _txtMobileNoController = TextEditingController();
  final _txtEmailController = TextEditingController();
  final _txtNicNoController = TextEditingController();
  final _txtAddressController = TextEditingController();

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  File? image;
  Map<String, dynamic> userData = {};
  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> getUserData() async {
    final nic = await UserService().requireLoggedInNic();
    if (nic == null) return;
    EasyLoading.show(status: 'Getting User Data');
    final snapshot = await FirebaseService.instance.getPublicUser(nic);

    if (!snapshot.exists || snapshot.value == null) {
      EasyLoading.dismiss();
      return;
    }

    final data = UserDataUtil.withDefaults(
      jsonDecode(jsonEncode(snapshot.value)) as Map<String, dynamic>,
      nic,
    );
    if (!mounted) return;
    setState(() {
      userData = data;
      _txtFNameController.text = UserDataUtil.field(data, 'Name');
      _txtEmailController.text = UserDataUtil.field(data, 'Email');
      _txtNicNoController.text = UserDataUtil.field(data, 'NIC', fallback: nic);
      _txtMobileNoController.text = UserDataUtil.field(data, 'Mobile');
      _txtAddressController.text = UserDataUtil.field(data, 'Address');
    });
    EasyLoading.dismiss();
  }

  void _onRefresh() async {
    await getUserData();
    _refreshController.refreshCompleted();
  }

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  @override
  void dispose() {
    _txtFNameController.dispose();
    _txtMobileNoController.dispose();
    _txtEmailController.dispose();
    _txtNicNoController.dispose();
    _txtAddressController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  String get _displayName {
    final name = UserDataUtil.field(userData, 'Name');
    if (name.isEmpty) return 'Citizen';
    return name;
  }

  String get _displayEmail {
    final email = UserDataUtil.field(userData, 'Email');
    return email.isEmpty ? '—' : email;
  }

  String get _displayNic {
    final nic = UserDataUtil.field(userData, 'NIC');
    return nic.isEmpty ? '—' : nic;
  }

  Future<void> _saveProfile() async {
    EasyLoading.show(status: 'Saving data...');
    try {
      final imageSkipped = await updateProfile(
        UserDataUtil.field(userData, 'NIC'),
        _txtFNameController.text,
        _txtAddressController.text,
        _txtEmailController.text,
        _txtMobileNoController.text,
        _imageFile?.path,
      );

      EasyLoading.dismiss();
      if (imageSkipped) {
        EasyLoading.showInfo(StorageService.sparkPlanMessage);
      } else {
        EasyLoading.showSuccess('Profile Updated Successfully!');
      }

      Future.delayed(const Duration(milliseconds: 1200), _onRefresh);
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError('Failed to update profile');
      debugPrint('$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<LanguageController>();
    final sysWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: appSurface,
      drawer: Drawer(child: DrawerWidget()),
      body: Column(
        children: [
          _buildHeader(sysWidth),
          Expanded(
            child: SmartRefresher(
              enablePullDown: true,
              header: WaterDropMaterialHeader(
                backgroundColor: secondary,
                color: appSurfaceElevated,
              ),
              controller: _refreshController,
              onRefresh: _onRefresh,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
                children: [
                  Transform.translate(
                    offset: const Offset(0, -36),
                    child: Column(
                      children: [
                        _buildIdentityCard(),
                        const SizedBox(height: 16),
                        _buildDetailsCard(),
                        const SizedBox(height: 16),
                        _buildSecurityCard(),
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

  Widget _buildHeader(double sysWidth) {
    return Container(
      width: double.infinity,
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
          padding: const EdgeInsets.fromLTRB(4, 8, 16, 52),
          child: Row(
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
                  tooltip: MaterialLocalizations.of(context)
                      .openAppDrawerTooltip,
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Profile'.tr(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Poppins-Bold',
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Citizen account details',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.72),
                        fontFamily: 'Poppins-Light',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIdentityCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      decoration: BoxDecoration(
        color: appSurfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: appBorder),
        boxShadow: [
          BoxShadow(
            color: secondary.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildAvatar(),
          const SizedBox(height: 14),
          Text(
            _displayName,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: secondary,
              fontFamily: 'Poppins-Bold',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _displayEmail,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: appTextMuted,
              fontFamily: 'Poppins-Light',
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: secondary.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: appBorder),
            ),
            child: Text(
              'NIC · $_displayNic',
              style: TextStyle(
                fontSize: 12,
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

  Widget _buildAvatar() {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: appAccent, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: secondary.withValues(alpha: 0.12),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 48,
            backgroundColor: appSurface,
            child: ClipOval(
              child: SizedBox(
                width: 96,
                height: 96,
                child: _imageFile != null
                    ? Image.file(
                        File(_imageFile!.path),
                        fit: BoxFit.cover,
                      )
                    : CachedNetworkImage(
                        imageUrl:
                            UserDataUtil.field(userData, 'ProfileImage'),
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Center(
                          child: SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: secondary,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Image.asset(
                          'assets/images/no-profile.png',
                          fit: BoxFit.cover,
                        ),
                      ),
              ),
            ),
          ),
        ),
        Material(
          color: secondary,
          shape: const CircleBorder(),
          elevation: 2,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: appSurfaceElevated,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                ),
                builder: (_) => bottomSheet(),
              );
            },
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Icon(Icons.camera_alt_rounded, size: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
      decoration: BoxDecoration(
        color: appSurfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: appBorder),
        boxShadow: [
          BoxShadow(
            color: secondary.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Personal information', Icons.badge_outlined),
          const SizedBox(height: 16),
          _field(
            controller: _txtFNameController,
            label: 'FulName'.tr(),
            icon: Icons.person_outline_rounded,
            keyboardType: TextInputType.name,
          ),
          const SizedBox(height: 14),
          _field(
            controller: _txtEmailController,
            label: 'Email'.tr(),
            icon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 14),
          _field(
            controller: _txtNicNoController,
            label: 'NIC'.tr(),
            icon: Icons.credit_card_outlined,
            readOnly: true,
          ),
          const SizedBox(height: 14),
          _field(
            controller: _txtMobileNoController,
            label: 'Mobile_No'.tr(),
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 14),
          _field(
            controller: _txtAddressController,
            label: 'Address'.tr(),
            icon: Icons.location_on_outlined,
            keyboardType: TextInputType.streetAddress,
            maxLines: 2,
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _saveProfile,
              icon: const Icon(Icons.save_outlined, size: 20),
              label: Text(
                'Save'.tr(),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins-Bold',
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: secondary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: appSurfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: appBorder),
        boxShadow: [
          BoxShadow(
            color: secondary.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Security', Icons.shield_outlined),
          const SizedBox(height: 14),
          Material(
            color: appSurface,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                ChangePasswordAlert().getAlert(context).show();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: secondary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.lock_outline_rounded, color: secondary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ChangePassword'.tr(),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: secondary,
                              fontFamily: 'Poppins-Bold',
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Update your account password',
                            style: TextStyle(
                              fontSize: 12,
                              color: appTextMuted,
                              fontFamily: 'Poppins-Light',
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, color: appTextSubtle),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: appAccent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Icon(icon, size: 18, color: secondary),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: secondary,
            fontFamily: 'Poppins-Bold',
          ),
        ),
      ],
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool readOnly = false,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      maxLines: maxLines,
      cursorColor: secondary,
      style: TextStyle(
        color: secondary,
        fontFamily: 'Poppins-Light',
        fontSize: 14,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: appTextMuted,
          fontFamily: 'Poppins-Light',
        ),
        prefixIcon: Icon(icon, color: appTextSubtle, size: 20),
        filled: true,
        fillColor: readOnly ? appSurface : Colors.white,
        contentPadding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: appBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: appBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: secondary, width: 1.4),
        ),
      ),
    );
  }

  Widget bottomSheet() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: appBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Update photo',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: secondary,
                fontFamily: 'Poppins-Bold',
              ),
            ),
            const SizedBox(height: 14),
            _sheetOption(
              icon: Icons.camera_alt_outlined,
              label: 'Camera',
              onTap: () {
                Navigator.pop(context);
                takePhoto(ImageSource.camera);
              },
            ),
            const SizedBox(height: 8),
            _sheetOption(
              icon: Icons.photo_library_outlined,
              label: 'Gallery',
              onTap: () {
                Navigator.pop(context);
                takePhoto(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _sheetOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: appSurface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: secondary, size: 22),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: secondary,
                  fontFamily: 'Poppins-Light',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void takePhoto(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile == null || !mounted) return;
    setState(() => _imageFile = pickedFile);
  }

  /// Returns true when profile text was saved but image upload was skipped.
  Future<bool> updateProfile(
    String NIC,
    String Name,
    String Address,
    String Email,
    String Mobile,
    String? newImagePath,
  ) async {
    await FirebaseService.instance.ensureAuthenticated();

    final databaseRef = FirebaseService.instance.rootRef;

    final data = <String, dynamic>{
      'Name': Name,
      'Address': Address,
      'Email': Email,
      'Mobile': Mobile,
      'NIC': NIC,
    };

    var imageUploadSkipped = false;

    if (newImagePath != null && newImagePath.isNotEmpty) {
      final imageUrl = await StorageService.uploadFileOrInline(
        storagePath: 'public-profile/$NIC.jpg',
        file: File(newImagePath),
        contentType: 'image/jpeg',
        timeout: const Duration(seconds: 45),
      );
      if (imageUrl != null) {
        data['ProfileImage'] = imageUrl;
      } else {
        imageUploadSkipped = true;
      }
    }

    await databaseRef.child('/PublicUsers/All/$NIC').update(data);
    return imageUploadSkipped;
  }
}
