import 'dart:convert';

import 'package:Akwad/mainScreen/result/result.dart';
import 'package:Akwad/models/shopsmodel.dart';
import 'package:Akwad/utils/constants.dart' as Constants;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../LocaleHelper.dart';
import '../../applocalizations.dart';

class Shops extends StatefulWidget {
  BuildContext parentContext;
  Shops(this.parentContext);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return ShopsState(parentContext);
  }
}

List<ShopsModel> shopModel = [];

class ShopsState extends State<Shops> {
  BuildContext parentContext;
  bool _load = false;
  SpecificLocalizationDelegate _specificLocalizationDelegate;
  AppLocalizations appLocalizations;

  String lang = Constants.Constants.appLang;

  ShopsState(this.parentContext);
  @override
  void initState() {
    // TODO: implement initState
    getLang();
    shopModel.clear();
    if (shopModel.isEmpty) {
      _load = true;
      fetchShops();
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

    double _height = MediaQuery.of(context).size.height;
    double _width = MediaQuery.of(context).size.width;

    // TODO: implement build
    return MaterialApp(localizationsDelegates: [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      new FallbackCupertinoLocalisationsDelegate(),
      //app-specific localization
      _specificLocalizationDelegate
    ],
      supportedLocales: [Locale('en'), Locale('ar')],
      locale: _specificLocalizationDelegate.overriddenLocale,
      debugShowCheckedModeBanner: false,home: Scaffold(body: Stack(
      children: <Widget>[
        GridView.count(
          crossAxisCount: 2,
          children: List.generate(shopModel.length, (index) {
            return GestureDetector(child:Container(
              margin: EdgeInsets.all(_width * 0.01),
              child: Column(
                children: <Widget>[
                  Container(
                      child: ClipOval(
                        child: Image.network(
                          shopModel[index].img,
                          width: _width * 0.2,
                          height: _width * 0.2,
                          fit: BoxFit.fill,
                        ),
                      ),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                              Radius.circular(40)),
                          border: Border.all(
                              width: 1,
                              color: Colors.white,
                              style: BorderStyle.solid))),
                  Container(
                    margin:
                    EdgeInsets.only(top: _height * 0.03),
                  ),
                  Container(
                    height: _height * 0.03,
                    child: FittedBox(
                      child: AutoSizeText(
                          shopModel[index].title,
                          minFontSize: 8.0,
                          maxFontSize: 10.0,
                          style: TextStyle(
                              color: Colors.black,
                              fontFamily: "Poppins",
                              fontWeight: FontWeight.bold,
                              decoration:
                              TextDecoration.none)),
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                ],
              ),
            ),onTap: (){
              Navigator.push(parentContext, MaterialPageRoute(builder: (context) => Result(type: "",id: shopModel[index].id,)));
            },);
          }),
        ),
        if(shopModel.isEmpty)
        Center(
          child: Text(
            appLocalizations.nodata,
            style: TextStyle(
                fontSize: 16.0,color: Colors.black, fontFamily: "Poppins"),
          ),
        ),
        loadingIndicator
      ],
      fit: StackFit.expand,
    ),),);
  }

  void fetchShops() async {
    await get(Constants.Constants.MainCategories).then((cates) {
      if(mounted)
      setState(() {
        _load = false;
      });
      List<dynamic> data = json.decode(cates.body)['data'];
      List<dynamic> shopesChilds = data[1]['childs'];

      for (var shop in shopesChilds) {
        if (mounted)
          setState(() {
            var singleModel =
                new ShopsModel(shop['id'], shop['image'], shop['name'][lang]);
            shopModel.add(singleModel);
          });
      }
    });
  }

  void getLang() async{
    await SharedPreferences.getInstance().then((value){
      if(mounted)
      setState(() {
        lang = value.getString("lang") ?? "en";
      });
    });

  }
}
