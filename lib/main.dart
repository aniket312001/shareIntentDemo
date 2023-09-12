import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sno_biz_app/app_route/app_route.dart';

import 'package:sno_biz_app/screens/splash_screen.dart';

import 'package:sno_biz_app/services/firebase_services.dart';
import 'package:sno_biz_app/services/loaderPercentage.dart';
import 'package:sno_biz_app/services/localization.dart';
import 'package:sno_biz_app/services/select_language.dart';
import 'package:sno_biz_app/utils/color_constants.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:uni_links/uni_links.dart';

import 'firebase_options.dart';

import 'dart:async';

import 'package:flutter_localizations/flutter_localizations.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseServices().initNotifications();


  runApp(const MyApp());
}




class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light
        .copyWith(statusBarColor: AppColors.purpleColor));
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LanguageChange()),
        ChangeNotifierProvider(create: (context) => LoaderPercentageChange())
      ],
      child: Consumer<LanguageChange>(
          builder: (context, languageChangeProvider, child) {
        return MaterialApp(
            navigatorKey: navigatorKey,
            title: 'Sno Demo',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              fontFamily: 'DM Sans',
              scaffoldBackgroundColor: Colors.white,

              appBarTheme: const AppBarTheme(
                backgroundColor: AppColors.purpleColor,
                elevation: 0,
              ),

              unselectedWidgetColor: AppColors
                  .purpleColor, // Set the border color for unselected checkbox
              checkboxTheme: CheckboxThemeData(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3),
                ),
                fillColor: MaterialStateColor.resolveWith(
                  (states) {
                    if (states.contains(MaterialState.selected)) {
                      return AppColors
                          .purpleColor; // Set the fill color for the checkbox when selected
                    }
                    return AppColors
                        .purpleColor; // Set the fill color for the checkbox when unselected
                  },
                ),
              ),
            ),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            locale: Locale(languageChangeProvider.getSelectedLanguage),
            // Locale(Provider.of<LanguageChange>(context).getSelectedLanguage),
            supportedLocales: const [
              Locale('en', 'US'),
              Locale('nl', 'NL'),
              Locale('fr', 'FR'),
            ],
            home: SplashScreen());
      }),
    );
  }
}
