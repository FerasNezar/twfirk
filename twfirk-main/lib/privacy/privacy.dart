import 'dart:convert';

import 'package:Akwad/utils/constants.dart' as Constants;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../LocaleHelper.dart';
import '../applocalizations.dart';

class Privacy extends StatefulWidget {
  int id = 0;
  String type = "";

  Privacy({Key key, this.type, this.id}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return PrivacyState(id);
  }
}

class PrivacyState extends State<Privacy> {
  SpecificLocalizationDelegate _specificLocalizationDelegate;
  AppLocalizations appLocalizations;

  int id = 0;

  String lang = Constants.Constants.appLang;

  String text = "";
  String title = "";
  String img = '';

  PrivacyState(this.id);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getLang();
    getContent();
  }

  onLocaleChange(Locale locale) {
    setState(() {
      _specificLocalizationDelegate = new SpecificLocalizationDelegate(locale);
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
        supportedLocales: [
          Locale('en'),
          Locale('ar')
        ],
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.fromLTRB(50.0, 80.0, 50.0, 50.0),
                  child: Container(
                    child: new Image.asset(
                      img,
                      width: 120.0,
                      height: 120.0,
                    ),
                    margin: EdgeInsets.all(8.0),
                  ),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadiusGeometry.lerp(
                          BorderRadius.circular(32.0),
                          BorderRadius.circular(32.0),
                          32.0)),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(50.0, 0, 50.0, 0),
                  child: Text(title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 30.0,
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
                  child: Text(text,
                      textAlign: TextAlign.start,
                      style: TextStyle(
                          fontSize: 20.0,
                          color: Colors.grey,
                          fontFamily: "Poppins",
                          decoration: TextDecoration.none)),
                ),
                if (id == 2)
                  Center(
                      child: Container(
                    width: 280.0,
                    margin: EdgeInsets.only(top: 40.0),
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(32.0),
                      ),
                      color: Colors.blue,
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(appLocalizations.accept,
                            style: TextStyle(
                                fontSize: 20.0,
                                color: Colors.white,
                                fontFamily: "Poppins",
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.none)),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ))
              ],
            ),
          ),
        ));
  }

  void getLang() async {
    await SharedPreferences.getInstance().then((value) {
      setState(() {
        lang = value.getString("lang") ?? "en";
        helper.onLocaleChanged(new Locale(lang,''));
      });
    });
  }

  void getContent() async {
    await get(Constants.Constants.Settings).then((models) {
      if (mounted)
        setState(() {
          if (id == 1) {
            title = appLocalizations.about;
            img = 'assets/images/logo.png';
            text = json.decode(models.body)['data']['about_$lang'];
          } else if (id == 2) {
            title = appLocalizations.privacy;
            img = 'assets/images/policy.png';
            text = json.decode(models.body)['data']['privacy_$lang'];
          } else if (id == 3) {
            title = appLocalizations.terms;
            img = 'assets/images/terms.png';
            text = json.decode(models.body)['data']['terms_$lang'];
          }
        });
    });
  }
}
