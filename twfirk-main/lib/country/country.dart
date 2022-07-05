import 'dart:convert';

import 'package:Akwad/models/langModel.dart';
import 'package:Akwad/utils/constants.dart' as Constants;
import 'package:Akwad/views/dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../LocaleHelper.dart';
import '../applocalizations.dart';

class Country extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return CountryState();
  }
}

List<LangModel> countries = [];

class CountryState extends State<Country> {
  SpecificLocalizationDelegate _specificLocalizationDelegate;
  AppLocalizations appLocalizations;
  bool _load = false;
  String lang = Constants.Constants.appLang;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _load = true;
    getPrefrances();
    fetchCountries();

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
    Widget loadingIndicator = _load
        ? new Container(
            color: Colors.grey[300],
            width: 70.0,
            height: 70.0,
            child: new Padding(
                padding: const EdgeInsets.all(5.0),
                child: new Center(child: new CircularProgressIndicator())),
          )
        : new Container();
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
      home: Scaffold(
        body: Stack(
          children: <Widget>[
            Image(
              width: double.infinity,
              height: double.infinity,
              image: AssetImage('assets/images/lang.png'),
              fit: BoxFit.fill,
            ),
            Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Image(
                        width: 180.0,
                        height: 180.0,
                        image: AssetImage("assets/images/flogo.png")),
                    Container(
                      margin: EdgeInsets.only(top: 25.0),
                    ),
                    Text(
                      appLocalizations.choose_lang,
                      style: TextStyle(
                          fontSize: 20.0,
                          color: Colors.white,
                          fontFamily: "Poppins",
                          decoration: TextDecoration.none),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 25.0),
                    ),
                    Dropdown([
                      LangModel(
                          0, 'assets/images/en.png', appLocalizations.langEn,false),
                      LangModel(
                          0, 'assets/images/ar.png', appLocalizations.langAr,false)
                    ],(val){
                      print("Selected : $val");
                      setState(() {
                        helper.onLocaleChanged(new Locale(val));
                      });
                    }),
                    Container(
                      margin: EdgeInsets.only(top: 25.0),
                    ),
                    if (countries.isNotEmpty) Dropdown(countries,(val){

                    }),
                    Container(
                      margin: EdgeInsets.only(top: 50.0),
                    ),
                    Container(
                        child: RaisedButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(32.0),
                      ),
                      color: Colors.white,
                      child: Text(
                        appLocalizations.next,
                        style: TextStyle(fontSize: 19.0, color: Colors.black),
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, "/Start");
                      },
                    ))
                  ]),
            ),
          ],
        ),
      ),
    );
  }

  getPrefrances() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      lang = prefs.getString("lang") ?? 'en';
      Constants.Constants.appLang = lang;
    });
  }

  void fetchCountries() async {
    await get(Constants.Constants.Countries).then((models) {
      setState(() {
        _load = false;
      });
      List<dynamic> data = json.decode(models.body)['data'];
      for (var item in data) {
        setState(() {
          LangModel lang =
              new LangModel(item['id'], item['image'], item['name'][this.lang],false);
          countries.add(lang);
        });
      }
    });
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
}
