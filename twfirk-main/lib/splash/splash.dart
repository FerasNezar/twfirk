import 'package:Akwad/utils/PushNotificationsManager.dart';
import 'package:Akwad/utils/constants.dart' as Constants;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../LocaleHelper.dart';
import '../applocalizations.dart';

class Splash extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return SplashState();
  }
}


class SplashState extends State<Splash> {
  SpecificLocalizationDelegate _specificLocalizationDelegate;
  AppLocalizations appLocalizations;
  String lang = Constants.Constants.appLang;

  onLocaleChange(Locale locale) {
    if (mounted)
      setState(() {
        _specificLocalizationDelegate =
        new SpecificLocalizationDelegate(locale);
      });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
   PushNotificationsManager().init();
    getPrefrances();
    getFirstScreen().then((val) {
      print(val);
      new Future.delayed(new Duration(seconds: 3), () {
        Navigator.pushReplacementNamed(context, val);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    appLocalizations = AppLocalizations();
    helper.onLocaleChanged = onLocaleChange;
    _specificLocalizationDelegate =
        SpecificLocalizationDelegate(new Locale(lang,''));

    // TODO: implement build
    return MaterialApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        new FallbackCupertinoLocalisationsDelegate(),
        //app-specific localization
        _specificLocalizationDelegate
      ],
      supportedLocales: [Locale('en'), Locale('ar')],
      locale: _specificLocalizationDelegate.overriddenLocale,
      debugShowCheckedModeBanner: false,
      home: Container(
          child: new Stack(
        children: <Widget>[
          Image(
            width: double.infinity,
            height: double.infinity,
            image: AssetImage('assets/images/splash.png'),
            fit: BoxFit.fill,
          ),
          Center(
            child: Image(
                width: 120.0,
                height: 120.0,
                image: AssetImage("assets/images/flogo.png")),
          ),
        ],
      )),
    );
  }

  Future<String> getFirstScreen() async {
    final prefs = await SharedPreferences.getInstance();
    String route;
    if (prefs.getBool("first") ?? false) {
      route = "/Main";
    } else {
      route = "/Country";
    }
    return route;
  }

  getPrefrances() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      lang = prefs.getString("lang") ?? 'en';
      Constants.Constants.appLang = lang;
      helper.onLocaleChanged(new Locale(lang,''));
    });
  }
}
