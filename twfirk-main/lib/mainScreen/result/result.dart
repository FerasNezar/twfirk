import 'dart:convert';

import 'package:Akwad/models/copouns.dart';
import 'package:Akwad/utils/constants.dart' as Constants;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:http/http.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../LocaleHelper.dart';
import '../../applocalizations.dart';

class Result extends StatefulWidget {
  int id = 0;
  String type = "";

  Result({Key key, this.type, this.id}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return ResultState(type, id);
  }
}

List<CouponsModel> offers = [];

class ResultState extends State<Result> {
  int id = 0;
  String type = "";
  String errorMsg = "";
  bool _load = false;
  bool _show = false;
  SpecificLocalizationDelegate _specificLocalizationDelegate;
  AppLocalizations appLocalizations;

  String lang = Constants.Constants.appLang;
  CouponsModel dialogModel;

  ResultState(this.type, this.id);

  @override
  void initState() {
    // TODO: implement initState
    getLang();
    _load = true;
    if (offers.isNotEmpty) offers.clear();
    if (id == 0) {
      fetchSearch(type);
    } else if (id == -1) {
      fetchAllCopuns();
    } else if (id == -2) {
      fetchAll();
    } else {
      fetchCopuns(id);
    }
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
        SpecificLocalizationDelegate(new Locale(lang, ''));

    double _height = MediaQuery.of(context).size.height;
    double _width = MediaQuery.of(context).size.width;

    errorMsg = appLocalizations.nodata;
    Widget loadingIndicator = _load
        ? new Container(
            color: Colors.grey[300],
            width: double.infinity,
            height: double.infinity,
            child: new Padding(
                padding: const EdgeInsets.all(5.0),
                child: new Center(child: new CircularProgressIndicator())),
          )
        : new Container();

    Widget dialog = _show
        ? new Container(
      width: _width * 0.7,
      height: _height * 0.4,
      decoration: BoxDecoration(
          color: Colors.grey[350],
          borderRadius: BorderRadiusGeometry.lerp(
              BorderRadius.circular(32.0),
              BorderRadius.circular(32.0),
              32.0),border: Border.all(
          width: 1,
          color: Colors.blue,
          style: BorderStyle.solid)),
      child: Column(
        children: <Widget>[
          Padding(
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.network(
                  dialogModel.img,
                  width: 40.0,
                  height: 40.0,
                ),
                DottedBorder(
                  borderType: BorderType.RRect,
                  color: Colors.black,
                  radius: Radius.circular(8.0),
                  padding: EdgeInsets.all(8.0),
                  strokeWidth: 1,
                  child: RichText(
                      overflow: TextOverflow.ellipsis,
                      strutStyle: StrutStyle(fontSize: 12.0),
                      text: TextSpan(
                          style: TextStyle(
                              color: Colors.black, fontFamily: "Poppins"),
                          text: dialogModel.code)),
                ),
              ],
            ),
            padding: EdgeInsets.all(16.0),
          ),
          Padding(child: Text(appLocalizations.copyMsg,
              style: TextStyle(
                  color: Colors.black,
                  fontFamily: "Poppins",
                  fontSize: 14.0)),padding: EdgeInsets.all(8.0),),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Flexible(
                  child: Container(
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(32.0),
                      ),
                      child: Text(
                        appLocalizations.yes,
                        style: TextStyle(
                            color: Colors.white, fontFamily: "Poppins"),
                      ),
                      color: Colors.blue,
                      onPressed: () {
                        setState(() {
                          _show = false;
                        });
                        _openUrl(dialogModel.link);
                      },
                    ),
                    margin: EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
                  ),
                  flex: 1,
                ),
                Flexible(
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(32.0),
                    ),
                    child: Text(
                      appLocalizations.no,
                      style: TextStyle(
                          color: Colors.black, fontFamily: "Poppins"),
                    ),
                    color: Colors.white,
                    onPressed: () {
                      setState(() {
                        _show = false;
                      });
                    },
                  ),
                  flex: 1,
                ),
              ],
            ),
          ),
//                RaisedButton(
//                  shape: RoundedRectangleBorder(
//                    borderRadius: new BorderRadius.circular(32.0),
//                  ),
//                  child: Text(
//                    appLocalizations.shoping,
//                    style:
//                        TextStyle(color: Colors.white, fontFamily: "Poppins"),
//                  ),
//                  color: Colors.blue,
//                  onPressed: () {
//                    setState(() {
//                      _show = false;
//                    });
//                    _openUrl(dialogModel.link);
//                  },
//                ),
        ],
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
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Container(
                decoration: BoxDecoration(shape: BoxShape.rectangle,
                    // BoxShape.circle or BoxShape.retangle
                    //color: const Color(0xFF66BB6A),

                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue,
                        blurRadius: 1.0,
                      ),
                    ]),
                width: double.infinity,
                height: _height * 0.17,
                child: Container(
                  margin: EdgeInsets.fromLTRB(
                      _width * 0.04, _height * 0.05, _width * 0.04, 0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          GestureDetector(
                            child: AutoSizeText(appLocalizations.currentlang,
                                textAlign: TextAlign.start,
                                maxFontSize: 12.0,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: "Poppins",
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.none)),
                            onTap: () {
                              changeLang(appLocalizations.currentlang);
                            },
                          ),
                          Expanded(
                            child: Container(
                              height: _height * 0.04,
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Image.asset(
                                    'assets/images/flogo.png',
                                    width: _width * 0.04,
                                  ),
                                  FittedBox(
                                    child: AutoSizeText(
                                        appLocalizations.appname,
                                        textAlign: TextAlign.center,
                                        minFontSize: 20.0,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: "Poppins",
                                            fontWeight: FontWeight.bold,
                                            decoration: TextDecoration.none)),
                                    fit: BoxFit.fitHeight,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Image.asset(
                            lang == "ar"
                                ? 'assets/images/ar.png'
                                : 'assets/images/en.png',
                            width: _width * 0.07,
                          )
                        ],
                      ),
                      Container(
                        height: _height * 0.05,
                        margin: EdgeInsets.all(_width * 0.02),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(32)),
                        ),
                        child: TextField(
                          textAlign: TextAlign.start,
                          textAlignVertical: TextAlignVertical.center,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: appLocalizations.search,
                            alignLabelWithHint: true,
                            contentPadding: EdgeInsets.all(_width * 0.022),
                            suffixIcon: Icon(Icons.search),
                          ),
                          textInputAction: TextInputAction.search,
                          onSubmitted: (val) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Result(
                                          type: val,
                                          id: 0,
                                        )));
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Flexible(
                child: Stack(
                  children: <Widget>[
                    if (offers.isNotEmpty)
                      ListView.builder(
                          scrollDirection: Axis.vertical,
                          itemCount: offers.length,
                          itemBuilder: (context, int index) {
                            return Container(
                                width: double.infinity,
                                margin: EdgeInsets.fromLTRB(8.0, 0, 8.0, 4.0),
                                child: Container(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: <Widget>[
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: <Widget>[
                                          Flexible(
                                            child: Container(
                                              width: double.infinity,
                                              child: Image.network(
                                                offers[index].img,
                                                width: _width * 0.1,
                                                height: _height * 0.07,
                                              ),
                                              margin: EdgeInsets.all(8.0),
                                            ),
                                            flex: 1,
                                          ),
                                          Flexible(
                                            child: Center(
                                                child: Row(
                                              children: <Widget>[
                                                Container(
                                                  height: _height * 0.04,
                                                  child: FittedBox(
                                                    child: AutoSizeText(
                                                        offers[index]
                                                                .discount
                                                                .toString() +
                                                            "%",
                                                        style: TextStyle(
                                                            fontSize: 18.0,
                                                            color: Colors.black,
                                                            fontFamily:
                                                                "Poppins",
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            decoration:
                                                                TextDecoration
                                                                    .none)),
                                                    fit: BoxFit.fitHeight,
                                                  ),
                                                ),
                                                Container(
                                                  margin: EdgeInsets.only(
                                                      left: 8.0),
                                                ),
                                                GestureDetector(
                                                  child: Icon(
                                                    Icons.share,
                                                    color: Colors.blue,
                                                    size: _width * 0.05,
                                                  ),
                                                  onTap: () {
                                                    Share.share(
                                                        "${offers[index].desc} Code : ${offers[index].code}");
                                                  },
                                                )
                                              ],
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                            )),
                                            flex: 1,
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: <Widget>[
                                          Expanded(
                                            child: Container(
                                              height: _height * 0.04,
                                              width: double.infinity,
                                              child: AutoSizeText(
                                                  offers[index].desc,
                                                  maxFontSize: 14.0,
                                                  maxLines: 1,
                                                  textAlign: TextAlign.start,
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontFamily: "Poppins",
                                                      fontSize: 14.0,
                                                      fontWeight:
                                                      FontWeight.bold,
                                                      decoration:
                                                      TextDecoration
                                                          .none)),
                                              padding: EdgeInsets.fromLTRB(
                                                  _width * 0.008,
                                                  _width * 0.008,
                                                  _width * 0.008,
                                                  _width * 0.008),
                                            ),
                                          ),
                                          Flexible(
                                            child: Center(
                                              child: Container(
                                                margin: EdgeInsets.all(
                                                    _width * 0.02),
                                                child: DottedBorder(
                                                    borderType:
                                                        BorderType.RRect,
                                                    color: Colors.black,
                                                    radius:
                                                        Radius.circular(8.0),
                                                    // padding: EdgeInsets.all(
                                                    //     _width * 0.01),
                                                    strokeWidth: 1,
                                                    child: Container(
                                                      width: _width * 0.4,
                                                      height: _height * 0.04,
                                                      child: Row(
                                                        children: <Widget>[
                                                          Expanded(
                                                            child: Container(
                                                              height: double
                                                                  .infinity,
                                                              width: double
                                                                  .infinity,
                                                              child: FittedBox(
                                                                child: AutoSizeText(
                                                                    offers[index]
                                                                        .code
                                                                        .toString(),
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            12.0,
                                                                        color: Colors
                                                                            .black,
                                                                        fontFamily:
                                                                            "Poppins",
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        decoration:
                                                                            TextDecoration.none)),
                                                                fit: BoxFit
                                                                    .fitHeight,
                                                              ),
                                                              margin: EdgeInsets
                                                                  .fromLTRB(
                                                                      _width *
                                                                          0.02,
                                                                      _width *
                                                                          0.01,
                                                                      _width *
                                                                          0.02,
                                                                      _width *
                                                                          0.01),
                                                            ),
                                                          ),
                                                          new GestureDetector(
                                                            child: Container(
                                                              height: 300.0,
                                                              color: Colors.transparent,
                                                              child: new Container(
                                                                decoration: new BoxDecoration(
                                                                  color: Colors.blue,
                                                                  borderRadius: lang == "ar" ? new BorderRadius.only(
                                                                    topLeft: const Radius.circular(8.0),
                                                                    bottomLeft: const Radius.circular(8.0),
                                                                    //topRight: const Radius.circular(10.0),
                                                                  ) : 
                                                                  new BorderRadius.only(
                                                                    topRight: const Radius.circular(8.0),
                                                                    bottomRight: const Radius.circular(8.0),
                                                                    //topRight: const Radius.circular(10.0),
                                                                  )
                                                                ),
                                                                child: new Center(
                                                                child: Padding(
                                                                  padding: EdgeInsets.symmetric(horizontal: 4.0),
                                                                  child: Text(
                                                            appLocalizations.copyCode,
                                                            textAlign: TextAlign.center,
                                                            overflow: TextOverflow.ellipsis,
                                                            style: TextStyle(
                                                              color: Colors.white,
                                                            fontSize: 13, 
                                                            fontWeight: FontWeight.bold,
                                                              fontFamily: "Poppins",
                                                                      ),
                                                          ),
                                                                  
                                                                  ),
                                                      )
                                                    ),
                                                    ),
                                                            onTap: () {
                                                              setState(() {
                                                                dialogModel =
                                                                    offers[
                                                                        index];
                                                                Clipboard.setData(
                                                                    new ClipboardData(text: dialogModel.code));
                                                                final scaffold = Scaffold.of(context);
                                                                scaffold.showSnackBar(SnackBar(
                                                                    content: new Text(appLocalizations.copied)));
                                                                _show = true;
                                                              });
                                                            },
                                                          )
                                                        ],
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                      ),
                                                    )),
                                              ),
                                            ),
                                            flex: 1,
                                          )
                                        ],
                                      ),
                                      Container(
                                        margin: EdgeInsets.all(8.0),
                                        height: _height * 0.05,
                                        width: double.infinity,
                                        child: RaisedButton(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                new BorderRadius.circular(32.0),
                                          ),
                                          child: AutoSizeText(
                                            appLocalizations.shoping,
                                            maxFontSize: 12.0,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontFamily: "Poppins"),
                                          ),
                                          color: Colors.blue,
                                          onPressed: () {
                                            Clipboard.setData(
                                                new ClipboardData(text: offers[index].code));
                                            final scaffold = Scaffold.of(context);
                                            scaffold.showSnackBar(SnackBar(
                                                content: new Text(appLocalizations.copied)));
                                            _openUrl(offers[index].link);
                                          },
                                        ),
                                      )
                                    ],
                                  ),
                                  margin:
                                      EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
                                ),
                                decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadiusGeometry.lerp(
                                        BorderRadius.circular(32.0),
                                        BorderRadius.circular(32.0),
                                        32.0)));
                          })
                    else
                      Center(
                        child: Text(
                          errorMsg,
                          style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.black,
                              fontFamily: "Poppins"),
                        ),
                      ),
                    Center(
                      child: loadingIndicator,
                    ),
                    Center(
                      child: dialog,
                    ),
                  ],
                ),
                flex: 1,
              )
            ],
          ),
        ));
  }

  void getLang() async {
    await SharedPreferences.getInstance().then((value) {
      setState(() {
        lang = value.getString("lang") ?? "en";
        helper.onLocaleChanged(new Locale(lang, ''));
      });
    });
  }

  void fetchSearch(String type) async {
    await get(Constants.Constants.Search + type).then((result) {
      setState(() {
        _load = false;
      });
      bool status = json.decode(result.body)['success'];
      if (status) {
        List<dynamic> data = json.decode(result.body)['data'];
        for (var i in data) {
          List<dynamic> copouns = i['coupons'];
          if (copouns.isNotEmpty)
            for (var c in copouns) {
              if (mounted)
                setState(() {
                  offers.add(new CouponsModel(
                      c['id'],
                      c['image'],
                      c['discount'],
                      c['description'][lang],
                      c['code'],
                      c['link']));
                });
            }
        }
      } else {
        setState(() {
          errorMsg = json.decode(result.body)['message'];
        });
      }
    });
  }

  void fetchCopuns(int id) async {
    await get("${Constants.Constants.SingleCategory}$id").then((result) {
      setState(() {
        _load = false;
      });
      if (offers.isNotEmpty) offers.clear();
      List<dynamic> data = json.decode(result.body)['data']['coupons'];
      if (data.isNotEmpty) {
        for (var i in data) {
          if (mounted)
            setState(() {
              offers.add(new CouponsModel(i['id'], i['image'], i['discount'],
                  i['description'][lang], i['code'], i['link']));
            });
        }
      } else {
        setState(() {});
      }
    });
  }

  _openUrl(String link) async {
    if (await canLaunch(Uri.encodeFull(link))) {
      await launch(Uri.encodeFull(link));
    } else {
      throw 'Could not launch $link';
    }
  }

  void callCopy(int id) async {
    String jsonParams = '{"coupon_id": $id}';
    Map<String, String> headers = {"Content-type": "application/json"};
    await post(Constants.Constants.CouponView,
            headers: headers, body: jsonParams)
        .then((response) {
      print(jsonParams);
      print(json.decode(response.body));
    });
  }

  changeLang(String type) async {
    print(type);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (type == "English" || type == "الانجليزية") {
      prefs.setString("lang", "en");
      Constants.Constants.appLang = "en";
      setState(() {
//        helper.onLocaleChanged(new Locale("en"));
        Navigator.pushNamedAndRemoveUntil(
            context, "/", (Route<dynamic> route) => false);
      });
    } else if (type == "Arabic" || type == "العربية") {
      prefs.setString("lang", "ar");
      Constants.Constants.appLang = "ar";
      setState(() {
//        helper.onLocaleChanged(new Locale("ar"));
        Navigator.pushNamedAndRemoveUntil(
            context, "/", (Route<dynamic> route) => false);
      });
    }
  }

  void fetchAllCopuns() async {
    await get(Constants.Constants.Coupons).then((result) {
      setState(() {
        _load = false;
      });
      List<dynamic> data = json.decode(result.body)['data'];
      for (var i in data) {
        setState(() {
          offers.add(new CouponsModel(i['id'], i['image'], i['discount'],
              i['description'][lang], i['code'], i['link']));
        });
      }
    });
  }

  void fetchAll() async {
    await get(Constants.Constants.All).then((result) {
      setState(() {
        _load = false;
      });
      List<dynamic> data = json.decode(result.body)['data']['all_coupons'];
      for (var i in data) {
        setState(() {
          offers.add(new CouponsModel(i['id'], i['image'], i['discount'],
              i['description'][lang], i['code'], i['link']));
        });
      }
    });
  }
}
