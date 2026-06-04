import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:safe_me/Resources/colors.dart';
import 'package:safe_me/content/legal_content.dart';
import 'package:safe_me/Screens/Legal/legal_document_screen.dart';

/// Checkbox label with tappable Terms and Privacy Policy links.
class LegalAcceptanceTitle extends StatelessWidget {
  const LegalAcceptanceTitle({super.key});

  @override
  Widget build(BuildContext context) {
    final isSinhala = context.locale.languageCode.toLowerCase().startsWith('si');
    final linkStyle = TextStyle(
      color: secondary,
      decoration: TextDecoration.underline,
      fontWeight: FontWeight.w600,
      fontFamily: 'Poppins-Light',
    );
    final baseStyle = TextStyle(
      color: textBlackColor,
      fontFamily: 'Poppins-Light',
    );

    if (isSinhala) {
      return RichText(
        text: TextSpan(
          style: baseStyle,
          children: [
            const TextSpan(text: 'මම '),
            TextSpan(
              text: 'නියම හා කොන්දේසි',
              style: linkStyle,
              recognizer: TapGestureRecognizer()
                ..onTap = () =>
                    LegalDocumentScreen.open(context, LegalDocumentType.terms),
            ),
            const TextSpan(text: ' සහ '),
            TextSpan(
              text: 'රහස්‍යතා ප්‍රතිපත්තිය',
              style: linkStyle,
              recognizer: TapGestureRecognizer()
                ..onTap = () =>
                    LegalDocumentScreen.open(context, LegalDocumentType.privacy),
            ),
            const TextSpan(text: ' කියවා එකඟ වෙමි.'),
          ],
        ),
      );
    }

    return RichText(
      text: TextSpan(
        style: baseStyle,
        children: [
          const TextSpan(text: 'I have read and agree to the '),
          TextSpan(
            text: 'Terms and Conditions',
            style: linkStyle,
            recognizer: TapGestureRecognizer()
              ..onTap = () =>
                  LegalDocumentScreen.open(context, LegalDocumentType.terms),
          ),
          const TextSpan(text: ' and '),
          TextSpan(
            text: 'Privacy Policy',
            style: linkStyle,
            recognizer: TapGestureRecognizer()
              ..onTap = () =>
                  LegalDocumentScreen.open(context, LegalDocumentType.privacy),
          ),
          const TextSpan(text: '.'),
        ],
      ),
    );
  }
}
