import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:safe_me/Controller/language_controller.dart';
import 'package:provider/provider.dart';
import 'package:safe_me/Screens/home_base.dart';
import 'Screens/Appoinment/appoinmentForm.dart';
import 'Screens/Appoinment/appointment_base.dart';
import 'Screens/Complaint/complaintForm.dart';
import 'Screens/LostAndFound/lost_Found.dart';
import 'Screens/loading.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await EasyLocalization.ensureInitialized();
   //SystemChrome.setEnabledSystemUIOverlays([]);
   SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageController()),
      ],
      child: EasyLocalization(
        supportedLocales: const [Locale('en', 'US'), Locale('si', 'SL')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en', 'US'),
        child: MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      debugShowCheckedModeBanner: false,
      builder: EasyLoading.init(),
      home: Loading(),
      // home: AppointmentBase(),
    );
  }
}
