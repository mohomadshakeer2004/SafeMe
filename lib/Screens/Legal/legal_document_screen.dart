import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:safe_me/content/legal_content.dart';
import 'package:safe_me/Resources/colors.dart';
import 'package:safe_me/Resources/style.dart';

class LegalDocumentScreen extends StatelessWidget {
  const LegalDocumentScreen({
    super.key,
    required this.type,
  });

  final LegalDocumentType type;

  @override
  Widget build(BuildContext context) {
    final languageCode = context.locale.languageCode;
    final title = LegalContent.title(type, languageCode);
    final body = LegalContent.body(type, languageCode);

    return Scaffold(
      backgroundColor: mainBGColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: mainBGColor,
        iconTheme: IconThemeData(color: buttonColor),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            color: secondary,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins-Light',
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Text(
          body.trim(),
          style: blackNormalTextStyle.copyWith(
            fontSize: 15,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  static void open(BuildContext context, LegalDocumentType type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LegalDocumentScreen(type: type),
      ),
    );
  }
}
