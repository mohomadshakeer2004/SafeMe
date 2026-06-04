enum LegalDocumentType { terms, privacy }

/// Static legal copy for Terms & Conditions and Privacy Policy screens.
class LegalContent {
  LegalContent._();

  static String title(LegalDocumentType type, String languageCode) {
    final isSinhala = languageCode.toLowerCase().startsWith('si');
    switch (type) {
      case LegalDocumentType.terms:
        return isSinhala ? 'නියම හා කොන්දේසි' : 'Terms and Conditions';
      case LegalDocumentType.privacy:
        return isSinhala ? 'රහස්‍යතා ප්‍රතිපත්තිය' : 'Privacy Policy';
    }
  }

  static String body(LegalDocumentType type, String languageCode) {
    final isSinhala = languageCode.toLowerCase().startsWith('si');
    if (type == LegalDocumentType.terms) {
      return isSinhala ? _termsSi : _termsEn;
    }
    return isSinhala ? _privacySi : _privacyEn;
  }

  static const String _termsEn = '''
Last updated: June 2026

Welcome to SafeMe. By using this application you agree to these Terms and Conditions.

1. Purpose of the app
SafeMe helps citizens report incidents, request police appointments, use emergency features, and access related public-safety services. The app is not a substitute for calling emergency services (119) when immediate danger exists.

2. User accounts
You must provide accurate information including your National Identity Card (NIC) number, contact details, and password. You are responsible for keeping your login credentials confidential.

3. Submissions and content
Information, photos, audio, and location data you submit must be truthful to the best of your knowledge. False or malicious reports may be referred to authorities and may result in suspension of access.

4. Emergency and SafeMe alerts
Shake-to-alert and emergency features may share your location and profile data with configured recipients and backend systems. Use these features only in genuine emergencies.

5. Availability
We strive to keep the service available but do not guarantee uninterrupted access. Maintenance, network issues, or third-party service limits may affect features.

6. Limitation of liability
SafeMe and its operators are not liable for indirect damages arising from use of the app, delays in response by authorities, or failures of telecommunications networks.

7. Changes
We may update these terms. Continued use of the app after updates constitutes acceptance of the revised terms.

8. Contact
For questions about these terms, contact your police station administrator or the SafeMe support channel provided by your organization.
''';

  static const String _termsSi = '''
අවසන් යාවත්කාලීනය: 2026 ජූනි

SafeMe භාවිතයට පෙර මෙම නියම හා කොන්දේසි කියවා එකඟ වන්න.

1. යෙදුමේ අරමුණ
SafeMe මගින් පුරවැසියන්ට සිදුවීම් වාර්තා කිරීම, පොලිස් හමුවීම් ඉල්ලීම, හදිසි අනතුරු විශේෂාංග සහ සම්බන්ධ ආරක්ෂක සේවා ලබා දෙයි. වහාම අනතුරක් ඇති විට 119 අමතන්න.

2. පරිශීලක ගිණුම්
ඔබේ NIC, සම්බන්ධතා විස්තර සහ මුරපදය නිවැරදිව ලබා දිය යුතුය. මුරපදය රහසිගතව තබා ගැනීම ඔබේ වගකීමයි.

3. ඉදිරිපත් කිරීම්
ඔබ යවන තොරතුරු, ඡායාරූප, ශබ්ද සටහන් සහ ස්ථාන දත්ත සත්‍ය විය යුතුය. ව්‍යාජ වාර්තා නීතිමය පියවරවලට ලක් විය හැක.

4. හදිසි අනතුරු විශේෂාංග
සෙල්ලම් හරහා අනතුරු ඇඟවීම් සහ හදිසි විශේෂාංග මගින් ස්ථාන දත්ත හුවමාරු විය හැක. සැබෑ හදිසි අවස්ථාවලදී පමණක් භාවිතා කරන්න.

5. සේවා ලබා ගැනීම
සේවාව අඛණ්ඩව ලබා දීමට උත්සාහ දරන අතර, ජාල ගැටලු හෝ නඩත්තු කාලයන් නිසා විශේෂාංග ප්‍රভාවිත විය හැක.

6. වගකීම් සීමා කිරීම
යෙදුම භාවිතයෙන් ඇති වන අනියම් හානි සඳහා SafeMe වගකිව නොසිටී.

7. වෙනස් කිරීම්
මෙම නියම වෙලෙස් කළ හැක. යාවත්කාලීනයෙන් පසු භාවිතය නව නියම පිළිගැනීමක් ලෙස සලකනු ලැබේ.

8. සම්බන්ධ වන්න
ප්‍රශ්න සඳහා ඔබේ පොලිස් ස්ථානයේ පරිපාලක හෝ SafeMe සහාය කණ්ඩායම අමතන්න.
''';

  static const String _privacyEn = '''
Last updated: June 2026

This Privacy Policy explains how SafeMe collects, uses, and protects your information.

1. Information we collect
• Account data: name, NIC, email, mobile number, address, profile image
• Submission data: complaints, appointments, SafeMe alerts, lost & found reports
• Media: photos, audio recordings, and documents you attach
• Location: GPS coordinates when you enable location or use emergency features
• Device data: basic technical logs needed to operate the app

2. How we use information
We use your data to authenticate you, store and display your submissions, share alerts with authorized police systems, and improve app reliability.

3. Storage and security
Data is stored in Firebase Realtime Database and related cloud services configured for the SafeMe project. Access requires authentication. No system is completely secure; report suspected misuse promptly.

4. Sharing
Your information may be visible to authorized police personnel handling your case. We do not sell personal data to advertisers.

5. Retention
Records may be retained as required by law and operational police procedures. You may request correction of inaccurate profile data through official channels.

6. Your choices
You can decline optional permissions (camera, microphone, location), but some features will not work. You may stop using the app and request account deactivation through your administrator.

7. Children
The app is intended for users who can lawfully enter into agreements under Sri Lankan law.

8. Updates
We may revise this policy. Material changes will be reflected in the app with an updated date.

9. Contact
Privacy questions should be directed to your police station or SafeMe program administrator.
''';

  static const String _privacySi = '''
අවසන් යාවත්කාලීනය: 2026 ජූනි

SafeMe ඔබේ තොරතුරු රැස් කිරීම, භාවිතය සහ ආරක්ෂාව මෙම ප්‍රතිපත්තියෙන් විස්තර කෙරේ.

1. අප රැස් කරන තොරතුරු
• ගිණුම් දත්ත: නම, NIC, ඊමේල්, දුරකථන අංකය, ලිපිනය
• ඉදිරිපත් කිරීම්: පැමිණිලි, හමුවීම්, SafeMe අනතුරු ඇඟවීම්
• මාධ්‍ය: ඡායාරූප, ශබ්ද සටහන්
• ස්ථානය: GPS ඛණ්ඩාංක
• උපාංග තාක්ෂණික ලොග්

2. භාවිතය
ඔබව සත්‍යාපනය කිරීම, ඉදිරිපත් කිරීම් සුරැකීම සහ අනුමත පොලිස් පද්ධති සමඟ හුවමාරු කිරීම සඳහා දත්ත භාවිතා කෙරේ.

3. ගබඩා කිරීම සහ ආරක්ෂාව
දත්ත SafeMe Firebase පද්ධතියේ ගබඩා වේ. සත්‍යාපනය අවශ්‍යය. සැක සහිත භාවිතය වහාම වාර්තා කරන්න.

4. හුවමාරු කිරීම
ඔබේ නඩුව හසුරුවන අනුමත පොලිස් කාර්ය මණ්ඩලයට තොරතුරු පෙනිය හැක. පෞද්ගලික දත්ත විකුණන්නේ නැත.

5. තබා ගැනීම
නීති සහ පොලිස් ක්‍රියා පටිපාටි අනුව වාර්තා තබා ගත හැක.

6. ඔබේ තේරීම්
අනුමති නොදීමේ විශේෂාංග ක්‍රියා නොකරයි. යෙදුම භාවිතය නවත්වා ගිණුම අක්‍රිය කිරීම ඉල්ලිය හැක.

7. ළමා පරිශීලකයින්
ශ්‍රී ලංකා නීතියට අනුකූලව ගිණුම් සඳහා වූ යෙදුමකි.

8. යාවත්කාලීන
මෙම ප්‍රතිපත්තිය වෙනස් කළ හැක.

9. සම්බන්ධ වන්න
රහස්‍යතා ප්‍රශ්න සඳහා ඔබේ පොලිස් ස්ථානය හෝ SafeMe පරිපාලක අමතන්න.
''';
}
