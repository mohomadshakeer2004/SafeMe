import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:safe_me/Screens/home_base.dart';
import 'package:safe_me/service/firebase_service.dart';
import 'package:safe_me/service/userService.dart';
import 'package:safe_me/util/user_data_util.dart';

import '../Resources/colors.dart';
import '../Screens/Legal/legal_document_screen.dart';
import '../Screens/Login/languageSelect.dart';
import '../content/legal_content.dart';

class DrawerWidget extends StatefulWidget {
  @override
  _DrawerWidgetState createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  Map<String, dynamic> userData = {};

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
    setState(() => userData = data);
    EasyLoading.dismiss();
  }

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  String get _name {
    final name = UserDataUtil.field(userData, 'Name');
    return name.isEmpty ? 'Citizen' : name;
  }

  String get _email {
    final email = UserDataUtil.field(userData, 'Email');
    return email.isEmpty ? '—' : email;
  }

  String get _nic {
    final nic = UserDataUtil.field(userData, 'NIC');
    return nic.isEmpty ? '—' : nic;
  }

  Future<void> _logout() async {
    Navigator.pop(context);
    try {
      await UserService().logout();
    } catch (_) {}
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SelectLanguage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: appSurface,
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(14, 16, 14, 12),
                children: [
                  _sectionLabel('Menu'),
                  const SizedBox(height: 8),
                  _menuCard([
                    _menuTile(
                      icon: Icons.home_outlined,
                      title: 'Home',
                      subtitle: 'Citizen services dashboard',
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HomeBase(),
                          ),
                        );
                      },
                    ),
                    _divider(),
                    _menuTile(
                      icon: Icons.language_rounded,
                      title: 'change_language'.tr(),
                      subtitle: 'English / Sinhala',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SelectLanguage(),
                          ),
                        );
                      },
                    ),
                  ]),
                  const SizedBox(height: 18),
                  _sectionLabel('Legal'),
                  const SizedBox(height: 8),
                  _menuCard([
                    _menuTile(
                      icon: Icons.description_outlined,
                      title: 'Terms_and_Conditions_Menu'.tr(),
                      subtitle: 'Service terms',
                      onTap: () {
                        Navigator.pop(context);
                        LegalDocumentScreen.open(
                          context,
                          LegalDocumentType.terms,
                        );
                      },
                    ),
                    _divider(),
                    _menuTile(
                      icon: Icons.privacy_tip_outlined,
                      title: 'Privacy_Policy_Menu'.tr(),
                      subtitle: 'How we use your data',
                      onTap: () {
                        Navigator.pop(context);
                        LegalDocumentScreen.open(
                          context,
                          LegalDocumentType.privacy,
                        );
                      },
                    ),
                  ]),
                  const SizedBox(height: 18),
                  _sectionLabel('Account'),
                  const SizedBox(height: 8),
                  _menuCard([
                    _menuTile(
                      icon: Icons.logout_rounded,
                      title: 'Logout',
                      subtitle: 'Sign out of SafeMe',
                      iconColor: emergencyPrimary,
                      titleColor: emergencyPrimary,
                      onTap: _logout,
                    ),
                  ]),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                'SafeMe · Citizen Portal',
                style: TextStyle(
                  fontSize: 11,
                  color: appTextSubtle,
                  fontFamily: 'Poppins-Light',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 20),
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Poppins-Bold',
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
                tooltip: 'Close',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(2.5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: appAccent, width: 2),
                ),
                child: CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white24,
                  child: ClipOval(
                    child: SizedBox(
                      width: 56,
                      height: 56,
                      child: CachedNetworkImage(
                        imageUrl:
                            UserDataUtil.field(userData, 'ProfileImage'),
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
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
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Poppins-Bold',
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.72),
                        fontFamily: 'Poppins-Light',
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'NIC · $_nic',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white,
                          fontFamily: 'Poppins-Light',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          letterSpacing: 0.8,
          fontWeight: FontWeight.w700,
          color: appTextMuted,
          fontFamily: 'Poppins-Bold',
        ),
      ),
    );
  }

  Widget _menuCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: appSurfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: appBorder),
        boxShadow: [
          BoxShadow(
            color: secondary.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _divider() {
    return Divider(height: 1, thickness: 1, color: appBorder, indent: 58);
  }

  Widget _menuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
    Color? titleColor,
  }) {
    final leadingColor = iconColor ?? secondary;
    final textColor = titleColor ?? secondary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: leadingColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: leadingColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                        fontFamily: 'Poppins-Bold',
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: appTextMuted,
                        fontFamily: 'Poppins-Light',
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: appTextSubtle, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}
