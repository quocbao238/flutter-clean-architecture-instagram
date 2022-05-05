import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:instegram/presentation/pages/login_page.dart';
import 'package:instegram/presentation/widgets/get_my_user_info.dart';
import 'package:instegram/presentation/widgets/multi_bloc_provider.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyApp extends StatefulWidget {
  final SharedPreferences sharePrefs;
  const MyApp({Key? key,required this.sharePrefs}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? myId;
  @override
  void initState() {
    myId=widget.sharePrefs.getString("myPersonalId");
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return MultiBloc(materialApp(context));
  }

  Widget materialApp(BuildContext context) {
    return Localizations(
        locale: const Locale('en'),
        delegates: const <LocalizationsDelegate<dynamic>>[
          DefaultMaterialLocalizations.delegate,
          DefaultWidgetsLocalizations.delegate,
        ],
        child: MaterialApp(
          locale: context.locale,
          supportedLocales: context.supportedLocales,
          localizationsDelegates: context.localizationDelegates,
          debugShowCheckedModeBanner: false,
          title: 'instagram',
          theme: ThemeData(
            appBarTheme: const AppBarTheme(
              elevation: 0,
              color: Colors.white,
            ),
            primarySwatch: Colors.grey,
            scaffoldBackgroundColor: Colors.white,
            canvasColor: Colors.transparent,
          ),
          home: AnimatedSplashScreen(
            centered: true,
            splash: Lottie.asset('assets/splash_gif/instagram.json'),
            nextScreen: myId==null
                ? LoginPage(sharePrefs: widget.sharePrefs)
                : GetMyPersonalId(myPersonalId: myId!),
          ),
        ));
  }
}