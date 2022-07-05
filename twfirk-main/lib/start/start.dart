import 'dart:convert';

import 'package:Akwad/utils/constants.dart' as Constants;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../LocaleHelper.dart';
import '../applocalizations.dart';

class Start extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return StartState();
  }
}

class StartState extends State<Start> {
  SpecificLocalizationDelegate _specificLocalizationDelegate;
  AppLocalizations appLocalizations;

  String lang = "";

  String title = "";
  String intro = "";
  String start = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (lang == "") getLang();
    getIntro();
  }

  onLocaleChange(Locale locale) {
    if (mounted)
      setState(() {
        _specificLocalizationDelegate =
        new SpecificLocalizationDelegate(locale);
      });
  }

  @override
  Widget build(BuildContext context) {
    appLocalizations = AppLocalizations();

    helper.onLocaleChanged = onLocaleChange;
    _specificLocalizationDelegate =
        SpecificLocalizationDelegate(new Locale(lang,''));
    // TODO: implement build
    if(lang == "en"){
      title = Constants.Constants.wEn;
      start = Constants.Constants.sEn;
    }else{
      title = Constants.Constants.wAr;
      start = Constants.Constants.sAr;
    }
    print(lang);
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
        home: Scaffold(
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.fromLTRB(50.0, 80.0, 50.0, 50.0),
                  child: new Image.asset(
                    'assets/images/intro.png',
                  ),
                ),
                if(title != "")
                Padding(
                  padding: EdgeInsets.fromLTRB(50.0, 0, 50.0, 0),
                  child: Text(title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 25.0,
                          color: Colors.black,
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.none)),
                ),
                Container(
                  margin: EdgeInsets.only(top: 20.0),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(50.0, 0, 50.0, 0),
                  child: Text(intro,
                      textAlign: TextAlign.start,
                      style: TextStyle(
                          fontSize: 20.0,
                          color: Colors.grey,
                          fontFamily: "Poppins",
                          decoration: TextDecoration.none)),
                ),
                if(start != "")
                Center(
                    child: Container(
                  width: 180.0,
                  margin: EdgeInsets.fromLTRB(0, 40.0, 0, 16.0),
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(32.0),
                    ),
                    color: Colors.blue,
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(start,
                          style: TextStyle(
                              fontSize: 20.0,
                              color: Colors.white,
                              fontFamily: "Poppins",
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.none)),
                    ),
                    onPressed: () {
                      SharedPreferences.getInstance().then((prefs){
                        prefs.setBool("first", true);
                        Navigator.pushNamedAndRemoveUntil(context, "/Main",(Route<dynamic> route) => false);
                      });
                    },
                  ),
                ))
              ],
            ),
          ),
        ));
  }

  void getLang() async {
    var shared = await SharedPreferences.getInstance();
    setState(() {
      lang = shared.getString("lang") ?? 'en';
      helper.onLocaleChanged(new Locale(lang,''));
    });
  }

  void getIntro() async {
    var request = await get(Constants.Constants.Settings);
    var models = request;
    if (mounted)
      setState(() {
        intro = json.decode(models.body)['data']['intro_$lang'];
      });

    var shared = await SharedPreferences.getInstance();

    lang = shared.getString("lang") ?? "en";
    shared.setString("facebook", json.decode(models.body)['data']['facebook']);
    shared.setString("instgram", json.decode(models.body)['data']['instgram']);
    shared.setString("twitter", json.decode(models.body)['data']['twitter']);
    shared.setString("email", json.decode(models.body)['data']['email']);
  }
}
