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

class Offers extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return OffersState();
  }
}

List<CouponsModel> offers = [];

class OffersState extends State<Offers> {
  bool _load = false;
  bool _show = false;
  CouponsModel dialogModel;

  SpecificLocalizationDelegate _specificLocalizationDelegate;
  AppLocalizations appLocalizations;

  String lang = Constants.Constants.appLang;

  @override
  void initState() {
    // TODO: implement initState
    getLang();
    offers.clear();
    if (offers.isEmpty) {
      _load = true;
      fetchOffers();
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
      supportedLocales: [Locale('en'), Locale('ar')],
      locale: _specificLocalizationDelegate.overriddenLocale,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Stack(
          children: <Widget>[
            if (offers.isNotEmpty)
              Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: offers.length,
                      itemBuilder: (context, int index) {
                        return Container(
                            width: double.infinity,
                            margin: EdgeInsets.fromLTRB(8.0, 0, 8.0, 4.0),
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
                                                          fontFamily: "Poppins",
                                                          fontWeight:
                                                          FontWeight.bold,
                                                          decoration:
                                                          TextDecoration
                                                              .none)),
                                                  fit: BoxFit.fitHeight,
                                                ),
                                              ),
                                              Container(
                                                margin:
                                                EdgeInsets.only(left: 8.0),
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
                                    Flexible(
                                      child: Container(
                                        height: _height * 0.04,
                                        width: double.infinity,
                                        child: Padding(
                                          child: FittedBox(
                                            child: AutoSizeText(
                                                offers[index].desc,
                                                maxFontSize: 14.0,
                                                maxLines: 2,
                                                overflow:
                                                TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontFamily: "Poppins",
                                                    fontSize: 14.0,
                                                    fontWeight:
                                                    FontWeight.bold,
                                                    decoration:
                                                    TextDecoration
                                                        .none)),
                                            fit: BoxFit.fitHeight,
                                          ),
                                          padding: EdgeInsets.fromLTRB(
                                              _width * 0.008,
                                              _width * 0.008,
                                              _width * 0.008,
                                              _width * 0.008),
                                        ),
                                      ),
                                      flex: 1,
                                    ),
                                    Flexible(
                                      child: Center(
                                        child: Container(
                                          margin:
                                          EdgeInsets.all(_width * 0.02),
                                          child: DottedBorder(
                                              borderType: BorderType.RRect,
                                              color: Colors.black,
                                              radius: Radius.circular(8.0),
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
                                                        height:
                                                        double.infinity,
                                                        width:
                                                        double.infinity,
                                                        child: FittedBox(
                                                          child: AutoSizeText(
                                                              offers[index]
                                                                  .code
                                                                  .toString(),
                                                              textAlign:
                                                              TextAlign
                                                                  .center,
                                                              overflow:
                                                              TextOverflow
                                                                  .ellipsis,
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
                                                                  TextDecoration
                                                                      .none)),
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
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadiusGeometry.lerp(
                                    BorderRadius.circular(32.0),
                                    BorderRadius.circular(32.0),
                                    32.0)));
                      })),
            if (offers.isEmpty)
              Center(
                child: Text(
                  appLocalizations.nodata,
                  style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.black,
                      fontFamily: "Poppins"),
                ),
              ),
            loadingIndicator,
            Center(child: dialog,),
          ],
        ),
      ),
    );
  }

  _openUrl(String link) async {
    if (await canLaunch(Uri.encodeFull(link))) {
      await launch(Uri.encodeFull(link));
    } else {
      throw 'Could not launch $link';
    }
  }

  void fetchOffers() async {
    await get(Constants.Constants.MainCategories).then((cates) {
      try {
        if (mounted)
          setState(() {
            _load = false;
          });
        List<dynamic> data = json.decode(cates.body)['data'];
        List<dynamic> copounsChilds = data[2]['coupons'];
        for (var cop in copounsChilds) {
          if (mounted)
            setState(() {
              var Coupon = new CouponsModel(
                  cop['id'],
                  cop['image'],
                  cop['discount'],
                  cop['description'][lang],
                  cop['code'],
                  cop['link']);
              offers.add(Coupon);
            });
        }
      } catch (e) {}
    });
  }

  void getLang() async {
    await SharedPreferences.getInstance().then((value) {
      if (mounted)
        setState(() {
          lang = value.getString("lang") ?? "en";
        });
    });
  }
}
