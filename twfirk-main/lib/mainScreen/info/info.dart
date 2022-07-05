import 'dart:convert';

import 'package:Akwad/models/langModel.dart';
import 'package:Akwad/privacy/privacy.dart';
import 'package:Akwad/utils/constants.dart' as Constants;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:http/http.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../LocaleHelper.dart';
import '../../applocalizations.dart';

class Info extends StatefulWidget {
  BuildContext parentContext;

  Info(this.parentContext);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return InfoState(parentContext);
  }
}

bool _notiSwitch = true;
List<LangModel> countries = [];
bool _load = false;

class InfoState extends State<Info> {
  SpecificLocalizationDelegate _specificLocalizationDelegate;
  AppLocalizations appLocalizations;

  String lang = "";
  String country = "";
  String facebook = "";
  String instagram = "";
  String twitter = "";
  String email = "";
  String share = "";
  BuildContext parentContext;
  List<LangModel> langModels = [];

  InfoState(this.parentContext);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _load = true;
    getLang();
    getIntro();
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
    _specificLocalizationDelegate =
        SpecificLocalizationDelegate(new Locale(lang, ''));

    double _height = MediaQuery.of(context).size.height;
    double _width = MediaQuery.of(context).size.width;

    Widget loadingIndicator = _load
        ? new Container(
            color: Colors.grey[300],
            width: double.infinity,
            height: double.infinity,
            child: new Padding(
              padding: const EdgeInsets.all(5.0),
              child: new Center(
                child: new CircularProgressIndicator(),
              ),
            ),
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
        supportedLocales: [
          Locale('en'),
          Locale('ar')
        ],
        locale: _specificLocalizationDelegate.overriddenLocale,
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Stack(
            children: <Widget>[
              SingleChildScrollView(
                  child: Container(
                      width: double.infinity,
                      margin: EdgeInsets.all(8.0),
                      child: Column(
                        children: <Widget>[
                          Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadiusGeometry.lerp(
                                      BorderRadius.circular(32.0),
                                      BorderRadius.circular(32.0),
                                      32.0)),
                              width: double.infinity,
                              child: Wrap(
                                children: <Widget>[
                                  Padding(
                                      padding: EdgeInsets.all(_height * 0.03),
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: <Widget>[
                                            Row(
                                              mainAxisSize: MainAxisSize.max,
                                              children: <Widget>[
                                                Flexible(
                                                  child: Container(
                                                    height: _height * 0.03,
                                                    width: double.infinity,
                                                    child: FittedBox(
                                                      child: AutoSizeText(
                                                          appLocalizations.lang,
                                                          maxFontSize: 14.0,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontFamily:
                                                                  "Poppins",
                                                              decoration:
                                                                  TextDecoration
                                                                      .none)),
                                                      alignment: lang == "ar"
                                                          ? Alignment
                                                              .centerRight
                                                          : Alignment
                                                              .centerLeft,
                                                      fit: BoxFit.fitHeight,
                                                    ),
                                                  ),
                                                  flex: 1,
                                                ),
                                                InfoDropdown(_height,
                                                    parentContext, langModels)
                                              ],
                                            ),
                                            Row(
                                              mainAxisSize: MainAxisSize.max,
                                              children: <Widget>[
                                                Flexible(
                                                  child: Container(
                                                    height: _height * 0.03,
                                                    width: double.infinity,
                                                    child: FittedBox(
                                                      child: AutoSizeText(
                                                          appLocalizations
                                                              .country,
                                                          maxFontSize: 15.0,
                                                          style: TextStyle(
                                                              fontSize: 15.0,
                                                              color:
                                                                  Colors.black,
                                                              fontFamily:
                                                                  "Poppins",
                                                              decoration:
                                                                  TextDecoration
                                                                      .none)),
                                                      alignment: lang == "ar"
                                                          ? Alignment
                                                              .centerRight
                                                          : Alignment
                                                              .centerLeft,
                                                      fit: BoxFit.fitHeight,
                                                    ),
                                                  ),
                                                  flex: 1,
                                                ),
                                                if (countries.isNotEmpty)
                                                  InfoDropdown(_height,
                                                      parentContext, countries),
                                              ],
                                            ),
                                            Container(
                                              margin: EdgeInsets.only(
                                                  top: _height * 0.001),
                                            ),
                                            Row(
                                              mainAxisSize: MainAxisSize.max,
                                              children: <Widget>[
                                                Flexible(
                                                  child: Container(
                                                    height: _height * 0.03,
                                                    width: double.infinity,
                                                    child: FittedBox(
                                                      child: AutoSizeText(
                                                          appLocalizations.noti,
                                                          maxFontSize: 15.0,
                                                          style: TextStyle(
                                                              fontSize: 15.0,
                                                              color:
                                                                  Colors.black,
                                                              fontFamily:
                                                                  "Poppins",
                                                              decoration:
                                                                  TextDecoration
                                                                      .none)),
                                                      alignment: lang == "ar"
                                                          ? Alignment
                                                              .centerRight
                                                          : Alignment
                                                              .centerLeft,
                                                      fit: BoxFit.fitHeight,
                                                    ),
                                                  ),
                                                  flex: 1,
                                                ),
                                                Switch(
                                                  value: _notiSwitch,
                                                  onChanged: _saveState,
//                                          onChanged: (bool value) {
//                                            setState(() {
//                                              _notiSwitch = value;
//                                            });
//                                          },
                                                  activeColor: Colors.blue,
                                                  inactiveTrackColor:
                                                      Colors.grey,
                                                ),
                                              ],
                                            ),
                                            Container(
                                              margin: EdgeInsets.only(
                                                  top: _height * 0.02),
                                            ),
                                            GestureDetector(
                                              child: Row(
                                                mainAxisSize: MainAxisSize.max,
                                                children: <Widget>[
                                                  Flexible(
                                                    child: Container(
                                                      height: _height * 0.03,
                                                      width: double.infinity,
                                                      child: FittedBox(
                                                        child: AutoSizeText(
                                                            appLocalizations
                                                                .about,
                                                            maxFontSize: 15.0,
                                                            style: TextStyle(
                                                                fontSize: 15.0,
                                                                color: Colors
                                                                    .black,
                                                                fontFamily:
                                                                    "Poppins",
                                                                decoration:
                                                                    TextDecoration
                                                                        .none)),
                                                        alignment: lang == "ar"
                                                            ? Alignment
                                                                .centerRight
                                                            : Alignment
                                                                .centerLeft,
                                                        fit: BoxFit.fitHeight,
                                                      ),
                                                    ),
                                                    flex: 1,
                                                  ),
                                                  Icon(
                                                    Icons.chevron_right,
                                                    color: Colors.grey,
                                                  ),
                                                ],
                                              ),
                                              onTap: () {
                                                Navigator.push(
                                                    parentContext,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            Privacy(
                                                              type: "",
                                                              id: 1,
                                                            )));
                                              },
                                            ),
                  
                                          ]))
                                ],
                              )),
                          Container(
                            margin: EdgeInsets.only(top: _height * 0.03),
                          ),
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.only(top: _height * 0.01),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    GestureDetector(
                                      child: new Image.asset(
                                        'assets/images/facebook.png',
                                        width: _height * 0.04,
                                        height: _height * 0.04,
                                      ),
                                      onTap: () {
                                        print(facebook);
                                        _openUrl(facebook);
                                      },
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(left: 50.0),
                                    ),
                                    GestureDetector(
                                      child: new Image.asset(
                                        'assets/images/twitter.png',
                                        width: _height * 0.04,
                                        height: _height * 0.04,
                                      ),
                                      onTap: () {
                                        _openUrl(twitter);
                                      },
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(left: 50.0),
                                    ),
                                    GestureDetector(
                                      child: new Image.asset(
                                        'assets/images/insta.png',
                                        width: _height * 0.04,
                                        height: _height * 0.04,
                                      ),
                                      onTap: () {
                                        _openUrl(instagram);
                                      },
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(left: 50.0),
                                    ),
                                    GestureDetector(
                                      child: new Image.asset(
                                        'assets/images/mail.png',
                                        width: _height * 0.04,
                                        height: _height * 0.04,
                                        color: Colors.grey,
                                      ),
                                      onTap: () {
                                        _openmail(email);
                                      },
                                    )
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    GestureDetector(
                                      child: Padding(
                                        child: AutoSizeText(
                                            appLocalizations.privacy,
                                            style: TextStyle(
                                                fontSize: 12.0,
                                                color: Colors.grey,
                                                fontFamily: "Poppins",
                                                decoration:
                                                    TextDecoration.none)),
                                        padding: EdgeInsets.all(_height * 0.03),
                                      ),
                                      onTap: () {
                                        Navigator.push(
                                            parentContext,
                                            MaterialPageRoute(
                                                builder: (context) => Privacy(
                                                      type: "",
                                                      id: 2,
                                                    )));
                                      },
                                    ),
                                    GestureDetector(
                                      child: Padding(
                                        child: AutoSizeText(
                                            appLocalizations.terms,
                                            style: TextStyle(
                                                fontSize: 12.0,
                                                color: Colors.grey,
                                                fontFamily: "Poppins",
                                                decoration:
                                                    TextDecoration.none)),
                                        padding: EdgeInsets.all(_height * 0.03),
                                      ),
                                      onTap: () {
                                        Navigator.push(
                                            parentContext,
                                            MaterialPageRoute(
                                                builder: (context) => Privacy(
                                                      type: "",
                                                      id: 3,
                                                    )));
                                      },
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ))),
              loadingIndicator
            ],
          ),
        ));
  }

  void getLang() async {
    await SharedPreferences.getInstance().then((value) {
      setState(() {
        lang = value.getString("lang") ?? "en";
        country = value.getString("country") ?? appLocalizations.ksa;
        facebook = value.getString("facebook") ?? "facebook.com";
        instagram = value.getString("instgram") ?? "instgram.com";
        twitter = value.getString("twitter") ?? "twitter.com";
        email = value.getString("email") ?? "info@Tawfirk.com";
        share = value.getString("share_message") ?? "http://www.Tawfirk.com/";
        _notiSwitch = value.getBool("noti") ?? true;
        langModels = [
          LangModel(
              0, 'assets/images/en.png', appLocalizations.langEn, lang == "en"),
          LangModel(
              0, 'assets/images/ar.png', appLocalizations.langAr, lang == "ar")
        ];
      });
    });
  }

  void fetchCountries() async {
    countries.clear();
    await get(Constants.Constants.Countries).then((models) {
      setState(() {
        _load = false;
      });
      try {
        List<dynamic> data = json.decode(models.body)['data'];
        for (var item in data) {
          setState(() {
            LangModel sLang = new LangModel(item['id'], item['image'],
                item['name'][this.lang], country == item['name'][lang]);
            countries.add(sLang);
          });
        }
      } catch (e) {
        setState(() {});
      }
    });
  }

  void _saveState(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("noti", value);
    setState(() {
      _notiSwitch = value;
    });
  }

  _openUrl(String link) async {
    if (await canLaunch(Uri.encodeFull(link))) {
      await launch(Uri.encodeFull(link));
    } else {
      throw 'Could not launch $link';
    }
  }

  void _openmail(String e) async {
    final Email email = Email(
      body: 'Email body',
      subject: 'Email subject',
      recipients: [e],
      isHTML: false,
    );

    await FlutterEmailSender.send(email);
  }

  void getIntro() async {
    await get(Constants.Constants.Settings).then((models) {
      try {
        SharedPreferences.getInstance().then((value) {
          value.setString(
              "facebook", json.decode(models.body)['data']['facebook']);
          value.setString(
              "instgram", json.decode(models.body)['data']['instgram']);
          value.setString(
              "twitter", json.decode(models.body)['data']['twitter']);
          value.setString("email", json.decode(models.body)['data']['email']);
        });
      } catch (e) {}
    });
  }
}

class InfoDropdown extends StatefulWidget {
  List<LangModel> langModels;
  BuildContext parentContext;
  double height;

  InfoDropdown(this.height, this.parentContext, this.langModels);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return AppState(parentContext, langModels);
  }
}

class AppState extends State<InfoDropdown> {
  List<LangModel> langModels;
  LangModel dropdownValue;
  BuildContext parentContext;

  AppState(this.parentContext, this.langModels) {
    dropdownValue = langModels[0];
    for (var m in langModels) {
      if (m.isSelected) {
        dropdownValue = m;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadiusGeometry.lerp(
                BorderRadius.circular(32.0), BorderRadius.circular(32.0), 32.0),
            color: Colors.white),
        child: Padding(
            padding: EdgeInsets.fromLTRB(
                widget.height * 0.001, 4.0, widget.height * 0.001, 4.0),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<LangModel>(
                isExpanded: false,
                value: dropdownValue,
                elevation: 16,
                style: TextStyle(
                  fontSize: 19.0,
                  color: Colors.black,
                  fontFamily: "Poppins",
                ),
                onChanged: changeLang,
                items: langModels
                    .map<DropdownMenuItem<LangModel>>((LangModel value) {
                  return DropdownMenuItem<LangModel>(
                    value: value,
                    child: Container(
                      height: widget.height * 0.03,
                      width: 90.0,
                      child: AutoSizeText(value.title,
                          maxFontSize: 15.0,
                          style: TextStyle(
                              fontSize: 15.0,
                              color: Colors.black,
                              fontFamily: "Poppins",
                              decoration: TextDecoration.none)),
                    ),
                  );
                }).toList(),
              ),
            )));
  }

  changeLang(LangModel model) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (model.title == "English" || model.title == "الانجليزية") {
      prefs.setString("lang", "en");
      Constants.Constants.appLang = "en";
      setState(() {
//        helper.onLocaleChanged(new Locale("en"));
        Navigator.pushNamedAndRemoveUntil(
            parentContext, "/", (Route<dynamic> route) => false);
      });
    } else if (model.title == "Arabic" || model.title == "العربية") {
      prefs.setString("lang", "ar");
      Constants.Constants.appLang = "ar";
      setState(() {
//        helper.onLocaleChanged(new Locale("ar"));
        Navigator.pushNamedAndRemoveUntil(
            parentContext, "/", (Route<dynamic> route) => false);
      });
    } else {
      prefs.setString("country", model.title);
    }

    setState(() {
      dropdownValue = model;
    });
  }
}
