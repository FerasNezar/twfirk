import 'dart:convert';

import 'package:Akwad/mainScreen/result/result.dart';
import 'package:Akwad/models/catemodel.dart';
import 'package:Akwad/models/copouns.dart';
import 'package:Akwad/utils/constants.dart' as Constants;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:http/http.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../LocaleHelper.dart';
import '../../applocalizations.dart';

class HomeScreen extends StatefulWidget {
  BuildContext parentContext;

  HomeScreen(this.parentContext);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return HomeState(parentContext);
  }
}

List<String> imgList = [];

List<CategoryModel> cateModel = [];

List<int> shopsIds = [];
List<String> shopsImgList = [];
List<String> shopsTitleList = [];

List<CouponsModel> coupons = [];
List<CouponsModel> allCoupons = [];

List<T> map<T>(List list, Function handler) {
  List<T> result = [];
  for (var i = 0; i < list.length; i++) {
    result.add(handler(i, list[i]));
  }

  return result;
}

List<Widget> child = [];

class HomeState extends State<HomeScreen> {
  BuildContext parentContext;
  bool _load = false;
  bool _show = false;
  SpecificLocalizationDelegate _specificLocalizationDelegate;
  AppLocalizations appLocalizations;

  String lang = "";
  CouponsModel dialogModel;

  HomeState(this.parentContext);

  int _currentCate = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (lang == "") getLang();

    imgList.clear();
    cateModel.clear();
    shopsIds.clear();
    shopsImgList.clear();
    shopsTitleList.clear();
    coupons.clear();
    allCoupons.clear();

    if (imgList.isEmpty) {
      _load = true;
      fetchSlider();
    }
    if (cateModel.isEmpty || shopsImgList.isEmpty || coupons.isEmpty) {
      _load = true;
      fetchMainCategories();
    }
    if (allCoupons.isEmpty) {
      _load = true;
      fetchAllCopounes();
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
        body: Stack(children: <Widget>[
          //------------------------------------------------------------------
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                if (imgList.isNotEmpty) CarouselWithIndicator(_height * 0.24),
                // if (cateModel.isNotEmpty)
                //   Container(
                //       width: double.infinity,
                //       height: _height * 0.2,
                //       margin: EdgeInsets.only(top: _height*0.06),
                //       child: ListView.builder(
                //         scrollDirection: Axis.horizontal,
                //         itemCount: cateModel.length,
                //         itemBuilder: (context, int index) {
                //           return GestureDetector(
                //             child: Container(
                //               margin: EdgeInsets.all(_width * 0.01),
                //               child: Column(
                //                 children: <Widget>[
                //                   Container(
                //                       child: ClipOval(
                //                         child: Image.network(
                //                           cateModel[index].img,
                //                           width: _width * 0.13,
                //                           height: _width * 0.13,
                //                           fit: BoxFit.fill,
                //                         ),
                //                       ),
                //                       decoration: BoxDecoration(
                //                           borderRadius: BorderRadius.all(
                //                               Radius.circular(40)),
                //                           border: Border.all(
                //                               width: 1,
                //                               color: Colors.white,
                //                               style: BorderStyle.solid))),
                //                   Container(
                //                     margin:
                //                         EdgeInsets.only(top: _height * 0.008),
                //                   ),
                //                   Container(
                //                     height: _height * 0.03,
                //                     child: FittedBox(
                //                       child: AutoSizeText(
                //                           cateModel[index].title,
                //                           minFontSize: 8.0,
                //                           maxFontSize: 10.0,
                //                           style: TextStyle(
                //                               color: Colors.black,
                //                               fontFamily: "Poppins",
                //                               fontWeight: FontWeight.bold,
                //                               decoration: TextDecoration.none)),
                //                       fit: BoxFit.fitHeight,
                //                     ),
                //                   )
                //                 ],
                //               ),
                //             ),
                //             onTap: () {
                //               Navigator.push(
                //                   parentContext,
                //                   MaterialPageRoute(
                //                       builder: (context) => Result(
                //                             type: "",
                //                             id: cateModel[index].id,
                //                           )));
                //             },
                //           );
                //         },
                //       )),
                Padding(
                    padding:
                        EdgeInsets.fromLTRB(_width * 0.04, 0, _width * 0.04, 0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        // Container(
                        //   width: 4.0,
                        //   height: _height * 0.04,
                        //   margin: EdgeInsets.symmetric(
                        //       vertical: 10.0, horizontal: 2.0),
                        //   decoration: BoxDecoration(
                        //       shape: BoxShape.rectangle, color: Colors.blue),
                        // ),
                        // Container(
                        //   height: _height * 0.04,
                        //   margin: EdgeInsets.only(left: 8.0,right: 8.0),
                        //   child: FittedBox(
                        //     child: AutoSizeText(appLocalizations.shops,
                        //         minFontSize: 10.0,
                        //         maxFontSize: 14.0,
                        //         style: TextStyle(
                        //             color: Colors.black,
                        //             fontFamily: "Poppins",
                        //             fontWeight: FontWeight.bold,
                        //             decoration: TextDecoration.none)),
                        //     fit: BoxFit.fitHeight,
                        //   ),
                        // ),
                        // Flexible(
                        //   child: Container(
                        //     height: _height * 0.03,
                        //     width: double.infinity,
                        //     child: GestureDetector(
                        //       child: FittedBox(
                        //         child: AutoSizeText(
                        //           appLocalizations.all,
                        //           textAlign: TextAlign.end,
                        //           style: TextStyle(
                        //               fontSize: 15.0,
                        //               color: Colors.black,
                        //               fontFamily: "Poppins",
                        //               fontWeight: FontWeight.bold,
                        //               decoration: TextDecoration.none),
                        //         ),
                        //         fit: BoxFit.fitHeight,
                        //         alignment: lang == "en"
                        //             ? Alignment.centerRight
                        //             : Alignment.centerLeft,
                        //       ),
                        //       onTap: () {
                        //         Navigator.push(
                        //             parentContext,
                        //             MaterialPageRoute(
                        //                 builder: (context) => Result(
                        //                       type: "",
                        //                       id: -2,
                        //                     )));
                        //       },
                        //     ),
                        //   ),
                        //   flex: 1,
                        // ),
                      ],
                    )),
                // if (shopsImgList.isNotEmpty)
                //   Container(
                //       width: double.infinity,
                //       height: _height * 0.2,
                //       child: ListView.builder(
                //           scrollDirection: Axis.horizontal,
                //           itemCount: shopsImgList.length,
                //           itemBuilder: (context, int index) {
                //             return GestureDetector(
                //               child: Container(
                //                 margin: EdgeInsets.all(_width * 0.01),
                //                 child: Column(
                //                   children: <Widget>[
                //                     Container(
                //                         child: ClipOval(
                //                           child: Image.network(
                //                             shopsImgList[index],
                //                             width: _width * 0.13,
                //                             height: _width * 0.13,
                //                             fit: BoxFit.fill,
                //                           ),
                //                         ),
                //                         decoration: BoxDecoration(
                //                             borderRadius: BorderRadius.all(
                //                                 Radius.circular(40)),
                //                             border: Border.all(
                //                                 width: 1,
                //                                 color: Colors.white,
                //                                 style: BorderStyle.solid))),
                //                     Container(
                //                       margin:
                //                           EdgeInsets.only(top: _height * 0.008),
                //                     ),
                //                     Container(
                //                       height: _height * 0.03,
                //                       child: FittedBox(
                //                         child: AutoSizeText(
                //                             shopsTitleList[index],
                //                             minFontSize: 8.0,
                //                             maxFontSize: 10.0,
                //                             style: TextStyle(
                //                                 color: Colors.black,
                //                                 fontFamily: "Poppins",
                //                                 fontWeight: FontWeight.bold,
                //                                 decoration:
                //                                     TextDecoration.none)),
                //                         fit: BoxFit.fitHeight,
                //                       ),
                //                     ),
                //                   ],
                //                 ),
                //               ),
                //               onTap: () {
                //                 Navigator.push(
                //                     parentContext,
                //                     MaterialPageRoute(
                //                         builder: (context) => Result(
                //                               type: "",
                //                               id: shopsIds[index],
                //                             )));
                //               },
                //             );
                //           })),
                if (coupons.isNotEmpty)
                  Padding(
                      padding: EdgeInsets.fromLTRB(
                          _width * 0.04, 0, _width * 0.04, 0),
                      child: Row(
                        children: <Widget>[
                          Container(
                            width: 4.0,
                            height: _height * 0.04,
                            margin: EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 2.0),

                            decoration: BoxDecoration(
                                shape: BoxShape.rectangle, color: Colors.blue),
                          ),
                          Container(
                              height: _height * 0.04,
                              margin: EdgeInsets.only(left: 8.0),
                              child: GestureDetector(
                                child: FittedBox(
                                  child: AutoSizeText(appLocalizations.offers,
                                      minFontSize: 10.0,
                                      maxFontSize: 14.0,
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontFamily: "Poppins",
                                          fontWeight: FontWeight.bold,
                                          decoration: TextDecoration.none)),
                                  fit: BoxFit.fitHeight,
                                ),
                                onTap: () {
                                  Navigator.push(
                                      parentContext,
                                      MaterialPageRoute(
                                          builder: (context) => Result(
                                                type: "",
                                                id: -1,
                                              )));
                                },
                              )),
                        ],
                      )),
                if (coupons.isNotEmpty)
                  Container(
                      width: double.infinity,
                      child: ListView.builder(
                          scrollDirection: Axis.vertical,
                          itemCount: coupons.length,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, int index) {
                            return Container(
                                width: double.infinity,
                                margin: EdgeInsets.fromLTRB(8.0, 0, 8.0, 4.0),
                                child: Container(child: Column(
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
                                              coupons[index].img,
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
                                                      coupons[index]
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
                                                      "${coupons[index].desc} Code : ${coupons[index].code}");
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
                                                child: AutoSizeText(
                                                    coupons[index].desc,
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
                                                                  coupons[index]
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
                                                        //COPY ICON CHANGE TO TEXT------------------------
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
                                                                  coupons[
                                                                      index];
                                                              _show = true;
                                                              Clipboard.setData(
                                                                  new ClipboardData(text: dialogModel.code));
                                                              final scaffold = Scaffold.of(context);
                                                              scaffold.showSnackBar(SnackBar(
                                                                  content: new Text(appLocalizations.copied)));
                                                            });
                                                          },
                                                        )
                                                      // new GestureDetector(
                                                      //     child: DecoratedBox (
                                                      //        decoration: const BoxDecoration(color: Colors.blue),
                                                      //       child: Text(
                                                      //       'Copy\n code',
                                                      //       textAlign: TextAlign.center,
                                                      //       overflow: TextOverflow.ellipsis,
                                                      //       style: TextStyle(
                                                      //         color: Colors.white,
                                                      //       fontSize: 12, 
                                                      //       fontWeight: FontWeight.bold),
                                                      //     ),
                                                        
                                                      //     ),
                                                      //     onTap: () {
                                                      //       setState(() {
                                                      //         dialogModel =
                                                      //             coupons[
                                                      //                 index];
                                                      //         _show = true;
                                                      //         Clipboard.setData(
                                                      //             new ClipboardData(text: dialogModel.code));
                                                      //         final scaffold = Scaffold.of(context);
                                                      //         scaffold.showSnackBar(SnackBar(
                                                      //             content: new Text(appLocalizations.copied)));
                                                      //       });
                                                      //     },
                                                      //   )
                                                        //OLD CODE BELOW ---------------------------------
                                                        // new GestureDetector(
                                                        //   child: Icon(
                                                        //     Icons.content_copy,
                                                        //     size: _width * 0.05,
                                                        //   ),
                                                        //   onTap: () {
                                                        //     setState(() {
                                                        //       dialogModel =
                                                        //           coupons[
                                                        //               index];
                                                        //       _show = true;
                                                        //       Clipboard.setData(
                                                        //           new ClipboardData(text: dialogModel.code));
                                                        //       final scaffold = Scaffold.of(context);
                                                        //       scaffold.showSnackBar(SnackBar(
                                                        //           content: new Text(appLocalizations.copied)));
                                                        //     });
                                                        //   },
                                                        // )
                                                        //--------------------------------------------------
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
                                              new ClipboardData(text: coupons[index].code));
                                          final scaffold = Scaffold.of(context);
                                          scaffold.showSnackBar(SnackBar(
                                              content: new Text(appLocalizations.copied)));
                                          _openUrl(coupons[index].link);
                                        },
                                      ),
                                    )
                                  ],
                                ),margin: EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),),
                                decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadiusGeometry.lerp(
                                        BorderRadius.circular(32.0),
                                        BorderRadius.circular(32.0),
                                        32.0)));
                          })),
                Padding(
                    padding:
                        EdgeInsets.fromLTRB(_width * 0.04, 0, _width * 0.04, 0),
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: 4.0,
                          height: _height * 0.04,
                          margin: EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 2.0),
                          decoration: BoxDecoration(
                              shape: BoxShape.rectangle, color: Colors.blue),
                        ),
                        Container(
                            height: _height * 0.04,
                            margin: EdgeInsets.only(left: 8.0),
                            child: GestureDetector(
                              child: FittedBox(
                                child: AutoSizeText(appLocalizations.all_copons,
                                    minFontSize: 10.0,
                                    maxFontSize: 14.0,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: "Poppins",
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.none)),
                                fit: BoxFit.fitHeight,
                              ),
                              onTap: () {
                                Navigator.push(
                                    parentContext,
                                    MaterialPageRoute(
                                        builder: (context) => Result(
                                              type: "",
                                              id: -1,
                                            )));
                              },
                            )),
                      ],
                    )),
                if (allCoupons.isNotEmpty)
                  Container(
                      width: double.infinity,
//                      height: _height * 0.4,
                      child: ListView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: allCoupons.length,
                          itemBuilder: (context, int index) {
                            return Container(
                                width: double.infinity,
                                margin: EdgeInsets.fromLTRB(8.0, 0, 8.0, 4.0),
                                child: Container(child: Column(
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
                                              allCoupons[index].img,
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
                                                          allCoupons[index]
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
                                                          "${allCoupons[index].desc} Code : ${allCoupons[index].code}");
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
                                                  child: AutoSizeText(
                                                      allCoupons[index].desc,
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

                                                padding: EdgeInsets.fromLTRB(
                                                    _width * 0.008,
                                                    _width * 0.008,
                                                    _width * 0.008,
                                                    _width * 0.008),
                                              )),
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
                                                                  allCoupons[
                                                                  index]
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
                                                          // child: Icon(
                                                          //   Icons.content_copy,
                                                          //   size: _width * 0.05,
                                                          // ),
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
                                                              allCoupons[
                                                              index];
                                                              _show = true;
                                                              Clipboard.setData(
                                                                  new ClipboardData(text: dialogModel.code));
                                                              final scaffold = Scaffold.of(context);
                                                              scaffold.showSnackBar(SnackBar(
                                                                  content: new Text(appLocalizations.copied)));
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
                                              new ClipboardData(text: allCoupons[index].code));
                                          final scaffold = Scaffold.of(context);
                                          scaffold.showSnackBar(SnackBar(
                                              content: new Text(appLocalizations.copied)));
                                          _openUrl(allCoupons[index].link);
                                        },
                                      ),
                                    )
                                  ],
                                ),margin: EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),),
                                decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadiusGeometry.lerp(
                                        BorderRadius.circular(32.0),
                                        BorderRadius.circular(32.0),
                                        32.0)));
                          })),
              ],
            ),
          ),
         //------------------------------------------------------------------
          new Align(
            child: loadingIndicator,
            alignment: FractionalOffset.center,
          ),
          new Align(
            child: dialog,
            alignment: FractionalOffset.center,
          ),
        ]),
      ),
    );
  }

  void fetchSlider() async {
    await get(Constants.Constants.Slider).then((result) {
      List<dynamic> data = json.decode(result.body)['data'];
      for (var i in data) {
        if (mounted)
          setState(() {
            _load = false;
            imgList.add(i['image']);
            child = map<Widget>(
              imgList,
              (index, i) {
                return Container(
                  margin: EdgeInsets.all(5.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    child: Stack(children: <Widget>[
                      Image.network(
                        i,
                        fit: BoxFit.fill,
                        width: 1000.0,
                        height: double.infinity,
                      ),
                      Positioned(
                        bottom: 0.0,
                        left: 0.0,
                        right: 0.0,
                        child: Container(
                          decoration: BoxDecoration(),
                          padding: EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 20.0),
                        ),
                      )
                    ]),
                  ),
                );
              },
            ).toList();
          });
      }
    });
  }

  void fetchMainCategories() async {
    await get(Constants.Constants.MainCategories).then((cates) {
      if (mounted)
        setState(() {
          _load = false;
        });
      List<dynamic> data = json.decode(cates.body)['data'];
      List<dynamic> categoriesChilds = data[0]['childs'];
      List<dynamic> copounsChilds = data[2]['coupons'];
      List<dynamic> shopesChilds = data[1]['childs'];
      for (var cate in categoriesChilds) {
        if (mounted)
          setState(() {
            var singleModel = new CategoryModel(
                cate['id'], cate['image'], cate['name'][lang]);
            cateModel.add(singleModel);
          });
      }

      shopsImgList.clear();
      shopsTitleList.clear();
      for (var shop in shopesChilds) {
        if (mounted)
          setState(() {
            shopsIds.add(shop['id']);
            shopsImgList.add(shop['image']);
            shopsTitleList.add(shop['name'][lang]);
          });
      }

      coupons.clear();
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
            coupons.add(Coupon);
          });
      }
    });
  }

  void getLang() async {
    await SharedPreferences.getInstance().then((value) {
      if (mounted)
        setState(() {
          lang = value.getString("lang") ?? "en";
          helper.onLocaleChanged(new Locale(lang, ''));
          AppLocalizations.load(new Locale(lang, ''));
        });
    });
  }

  _openUrl(String link) async {
    if (await canLaunch(Uri.encodeFull(link))) {
      await launch(Uri.encodeFull(link));
    } else {
      throw 'Could not launch $link';
    }
  }

  void fetchAllCopounes() async {
    await get(Constants.Constants.Coupons).then((cop) {
      setState(() {
        _load = false;
      });
      List<dynamic> data = json.decode(cop.body)['data'];
      for (var i = 0; i < 3; i++) {
        setState(() {
          allCoupons.add(new CouponsModel(
              data[i]['id'],
              data[i]['image'],
              data[i]['discount'],
              data[i]['description'][lang],
              data[i]['code'],
              data[i]['link']));
        });
      }
    });
  }
}

class CarouselWithIndicator extends StatefulWidget {
  double height;

  CarouselWithIndicator(this.height);

  @override
  _CarouselWithIndicatorState createState() => _CarouselWithIndicatorState();
}

class _CarouselWithIndicatorState extends State<CarouselWithIndicator> {
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      CarouselSlider(
        items: child,
        autoPlay: true,
        height: widget.height,
        aspectRatio: MediaQuery.of(context).size.aspectRatio,
        onPageChanged: (index) {
          setState(() {
            _current = index;
          });
        },
      ),
//      Row(
//        mainAxisAlignment: MainAxisAlignment.center,
//        children: map<Widget>(
//          imgList,
//          (index, url) {
//            return Container(
//              width: 32.0,
//              height: 4.0,
//              margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
//              decoration: BoxDecoration(
//                  shape: BoxShape.rectangle,
//                  color: _current == index
//                      ? Colors.blue
//                      : Color.fromRGBO(0, 0, 0, 0.4)),
//            );
//          },
//        ),
//      ),
    ]);
  }
}
