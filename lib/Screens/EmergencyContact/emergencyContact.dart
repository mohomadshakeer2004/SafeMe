import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:provider/provider.dart';

import '../../Controller/language_controller.dart';
import '../../Resources/colors.dart';
import '../../widgets/drawer.dart';
import '../Complaint/complaint_ui.dart';
import '../home_base.dart';
import 'emergency_contacts_data.dart';

class EmergencyContact extends StatefulWidget {
  const EmergencyContact({Key? key}) : super(key: key);

  @override
  _EmergencyContactState createState() => _EmergencyContactState();
}

class _EmergencyContactState extends State<EmergencyContact> {
  String _formatNumber(String number) {
    if (number.length == 3 || number.length == 4) return number;
    if (number.startsWith('011') && number.length == 10) {
      return '${number.substring(0, 3)} ${number.substring(3, 6)} ${number.substring(6)}';
    }
    return number;
  }

  Future<void> _callNumber(String number) async {
    await FlutterPhoneDirectCaller.callNumber(number);
  }

  Widget _buildContactCard(SriLankaEmergencyContact contact) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _callNumber(contact.number),
          borderRadius: BorderRadius.circular(ComplaintUi.radius),
          child: Ink(
            decoration: ComplaintUi.cardDecoration(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: emergencyPrimary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      contact.icon,
                      color: emergencyPrimary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          contact.nameKey.tr(),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: secondary,
                            fontFamily: 'Poppins-Bold',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatNumber(contact.number),
                          style: TextStyle(
                            fontSize: 14,
                            color: appTextMuted,
                            fontFamily: 'Poppins-Light',
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: secondary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.phone_in_talk_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<LanguageController>();
    final sysWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: appSurface,
      appBar: ComplaintUi.appBar(
        context: context,
        title: 'Contact'.tr(),
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
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  emergencyPrimary,
                  Color.lerp(emergencyPrimary, emergencySecondary, 0.4)!,
                ],
              ),
              borderRadius: BorderRadius.circular(ComplaintUi.radius),
            ),
            child: Row(
              children: [
                const Icon(Icons.emergency_share_rounded, color: Colors.white, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Emergency_Contacts_Info'.tr(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontFamily: 'Poppins-Light',
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...sriLankaEmergencyContacts.map(_buildContactCard),
        ],
      ),
    );
  }
}
