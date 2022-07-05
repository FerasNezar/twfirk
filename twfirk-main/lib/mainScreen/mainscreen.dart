import 'package:Akwad/mainScreen/categories/categories.dart';
import 'package:Akwad/mainScreen/home/home.dart';
import 'package:Akwad/mainScreen/info/info.dart';
import 'package:Akwad/mainScreen/offers/offers.dart';
import 'package:Akwad/mainScreen/result/result.dart';
import 'package:Akwad/mainScreen/shops/shops.dart';
import 'package:Akwad/utils/constants.dart';
import 'package:Akwad/utils/constants.dart' as Constants;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../LocaleHelper.dart';
import '../applocalizations.dart';

class MainScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return MainScreenState();
  }
}

class MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  SpecificLocalizationDelegate _specificLocalizationDelegate;
  AppLocalizations appLocalizations;

  String lang = "";

  int _selectedIndex = 0;
  int _currentIndex = 0;
  TabController _tabController;
  List<Widget> _tabList = [];

  String cuntry = "";

  @override
  void initState() {
    super.initState();
    _tabList = [
      HomeScreen(context),
      Categories(context),
      Shops(context),
      Offers(),
      Info(context)
    ];
    if (lang == "") getLang();
    _tabController = TabController(vsync: this, length: _tabList.length);
    _tabController.addListener(() {
      setState(() {
        _selectedIndex = _tabController.index;
      });
    });
  }

  onLocaleChange(Locale locale) {
    if (mounted)
      setState(() {
        _specificLocalizationDelegate =
            new SpecificLocalizationDelegate(locale);
      });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    appLocalizations = AppLocalizations();

    helper.onLocaleChanged = onLocaleChange;
    _specificLocalizationDelegate =
        SpecificLocalizationDelegate(new Locale(lang, ''));
    // TODO: implement build

    double _height = MediaQuery.of(context).size.height;
    double _width = MediaQuery.of(context).size.width;

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
        body: Column(
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
                margin: EdgeInsets.fromLTRB(_width * 0.04 , _height *0.05, _width * 0.04 , 0),
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
                            child: Container(height: _height*0.04,child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Image.asset(
                                  'assets/images/flogo.png',
                                  width: _width * 0.08,
                                ),FittedBox(child: AutoSizeText(appLocalizations.appname,
                                    textAlign: TextAlign.center,minFontSize: 20.0,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: "Poppins",
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.none)),fit: BoxFit.fitHeight,),
                              ],
                            ),),
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
                      height: _height*0.05,
                      margin: EdgeInsets.all(_width * 0.02),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(32)),
                      ),
                      child:TextField(
                        textAlign: TextAlign.start,
                        textAlignVertical: TextAlignVertical.center,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: appLocalizations.search,
                          alignLabelWithHint: true,
                          contentPadding: EdgeInsets.all(_width*0.022),
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
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: _tabList,
              ),
            )
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
                icon: Icon(Icons.home), title: Text(appLocalizations.home)),
            BottomNavigationBarItem(
                icon: Icon(Icons.dashboard),
                title: Text(appLocalizations.categories)),
            BottomNavigationBarItem(
                icon: Icon(Icons.store), title: Text(appLocalizations.shops)),
            BottomNavigationBarItem(
                icon: Icon(Icons.local_offer),
                title: Text(appLocalizations.offers)),
            BottomNavigationBarItem(
                icon: Icon(Icons.more_horiz),
                title: Text(appLocalizations.info)),
          ],
          currentIndex: _selectedIndex,
          onTap: (int index) {
            setState(() {
              _currentIndex = index;
              _selectedIndex = index;
            });
            _tabController.animateTo(_currentIndex);
          },
          fixedColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          elevation: 4.0,
        ),
      ),
    );
  }

  void getLang() async {
    await SharedPreferences.getInstance().then((value) {
      setState(() {
        lang = value.getString("lang") ?? "en";
        cuntry = value.getString("country") ?? appLocalizations.ksa;
        helper.onLocaleChanged(new Locale(lang, ''));
        AppLocalizations.load(new Locale(lang, ''));
      });
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
}
