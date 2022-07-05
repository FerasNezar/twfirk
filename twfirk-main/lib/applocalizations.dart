import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'l10n/messages_all.dart';

class AppLocalizations {

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static Future<AppLocalizations> load(Locale locale) {
    final String name =
        locale.countryCode == null ? locale.languageCode : locale.toString();
    final String localeName = Intl.canonicalizedLocale(name);

    return initializeMessages(localeName).then((bool _) {
      Intl.defaultLocale = localeName;
      return new AppLocalizations();
    });
  }

  String get copyMsg {
    return Intl.message('Copuon Copied ,Do you want to Shop now ?', name: 'copyMsg');
  }
  //Copy code
  String get copyCode {
    return Intl.message('Copy code', name: 'copyCode');
  }
  String get yes {
    return Intl.message('Yes', name: 'yes');
  }

  String get copy {
    return Intl.message('Copy', name: 'copy');
  }

  String get no {
    return Intl.message('No', name: 'no');
  }

  String get langEn {
    return Intl.message('English', name: 'langEn');
  }

  String get welcome {
    return Intl.message('Welcome To Tawfirk', name: 'welcome');
  }

  String get categories {
    return Intl.message('Categories', name: 'categories');
  }

  String get shops {
    return Intl.message('Shops', name: 'shops');
  }

  String get all {
    return Intl.message('All', name: 'all');
  }

  String get all_copons {
    return Intl.message('Latest Coupons', name: 'all_copons');
  }

  String get copied {
    return Intl.message('Copied to Clipboard', name: 'copied');
  }

  String get lang {
    return Intl.message('Language', name: 'lang');
  }

  String get country {
    return Intl.message('Country', name: 'country');
  }

  String get noti {
    return Intl.message('Notifications', name: 'noti');
  }

  String get about {
    return Intl.message('About Tawfirk', name: 'about');
  }

  String get rate {
    return Intl.message('Rate App', name: 'rate');
  }

  String get share {
    return Intl.message('Share App', name: 'share');
  }

  String get privacy {
    return Intl.message('Privacy Policy', name: 'privacy');
  }

  String get terms {
    return Intl.message('Terms of use', name: 'terms');
  }

  String get home {
    return Intl.message('Home', name: 'home');
  }

  String get stores {
    return Intl.message('Stores', name: 'stores');
  }

  String get offers {
    return Intl.message('Offers', name: 'offers');
  }

  String get info {
    return Intl.message('Info', name: 'info');
  }

  String get langAr {
    return Intl.message('Arabic', name: 'langAr');
  }

  String get ksa {
    return Intl.message('Ksa', name: 'ksa');
  }

  String get eng {
    return Intl.message('England', name: 'eng');
  }

  String get choose_lang {
    return Intl.message('Choose Language & Country', name: 'choose_lang');
  }

  String get next {
    return Intl.message('Next', name: 'next');
  }

  String get start {
    return Intl.message('Start', name: 'start');
  }

  String get currentlang {
    return Intl.message('العربية', name: 'currentlang');
  }

  String get shoping {
    return Intl.message('Shoping', name: 'shoping');
  }

  String get accept {
    return Intl.message('Confirm & Agree', name: 'accept');
  }

  String get nodata {
    return Intl.message('No Data !', name: 'nodata');
  }

  String get search {
    return Intl.message(' ', name: 'search');
  }

  String get appname {
    return Intl.message('Tawfirk', name: 'appname');
  }
}

class SpecificLocalizationDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  final Locale overriddenLocale;

  SpecificLocalizationDelegate(this.overriddenLocale);

  @override
  bool isSupported(Locale locale) => overriddenLocale != null;

  @override
  Future<AppLocalizations> load(Locale locale) =>
      AppLocalizations.load(overriddenLocale);

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalizations> old) => true;
}

class FallbackCupertinoLocalisationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const FallbackCupertinoLocalisationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ar'].contains(locale.languageCode);

  @override
  Future<CupertinoLocalizations> load(Locale locale) =>
      SynchronousFuture<_DefaultCupertinoLocalizations>(
          _DefaultCupertinoLocalizations(locale));

  @override
  bool shouldReload(FallbackCupertinoLocalisationsDelegate old) => false;
}

class _DefaultCupertinoLocalizations extends DefaultCupertinoLocalizations {
  final Locale locale;

  _DefaultCupertinoLocalizations(this.locale);
}
