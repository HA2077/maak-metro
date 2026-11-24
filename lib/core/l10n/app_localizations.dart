import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In ar, this message translates to:
  /// **'معاك'**
  String get appName;

  /// No description provided for @tabPlanner.
  ///
  /// In ar, this message translates to:
  /// **'التخطيط'**
  String get tabPlanner;

  /// No description provided for @tabLines.
  ///
  /// In ar, this message translates to:
  /// **'الخطوط'**
  String get tabLines;

  /// No description provided for @tabLibrary.
  ///
  /// In ar, this message translates to:
  /// **'محفوظات'**
  String get tabLibrary;

  /// No description provided for @tabSettings.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get tabSettings;

  /// No description provided for @plannerTitle.
  ///
  /// In ar, this message translates to:
  /// **'خطّط مشوارك'**
  String get plannerTitle;

  /// No description provided for @plannerHint.
  ///
  /// In ar, this message translates to:
  /// **'اختر محطتي البداية والنهاية لعرض أفضل مسار'**
  String get plannerHint;

  /// No description provided for @fromLabel.
  ///
  /// In ar, this message translates to:
  /// **'من'**
  String get fromLabel;

  /// No description provided for @toLabel.
  ///
  /// In ar, this message translates to:
  /// **'إلى'**
  String get toLabel;

  /// No description provided for @selectStation.
  ///
  /// In ar, this message translates to:
  /// **'اختر محطة'**
  String get selectStation;

  /// No description provided for @searchStations.
  ///
  /// In ar, this message translates to:
  /// **'ابحث باسم المحطة'**
  String get searchStations;

  /// No description provided for @noStationsFound.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد محطة بهذا الاسم'**
  String get noStationsFound;

  /// No description provided for @swapStations.
  ///
  /// In ar, this message translates to:
  /// **'تبديل المحطتين'**
  String get swapStations;

  /// No description provided for @findRoute.
  ///
  /// In ar, this message translates to:
  /// **'اعرض المسار'**
  String get findRoute;

  /// No description provided for @sameStationError.
  ///
  /// In ar, this message translates to:
  /// **'محطة البداية والنهاية واحدة'**
  String get sameStationError;

  /// No description provided for @noRouteError.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد مسار بين المحطتين'**
  String get noRouteError;

  /// No description provided for @recentSearches.
  ///
  /// In ar, this message translates to:
  /// **'آخر عمليات البحث'**
  String get recentSearches;

  /// No description provided for @routeTitle.
  ///
  /// In ar, this message translates to:
  /// **'المسار'**
  String get routeTitle;

  /// No description provided for @estimatedTime.
  ///
  /// In ar, this message translates to:
  /// **'الوقت التقديري {minutes} دقيقة'**
  String estimatedTime(String minutes);

  /// No description provided for @stationsCount.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =0{لا محطات} =1{محطة واحدة} =2{محطتان} few{{count} محطات} many{{count} محطة} other{{count} محطة}}'**
  String stationsCount(int count);

  /// No description provided for @transfersCount.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =0{بدون تغيير} =1{تغيير واحد} =2{تغييران} few{{count} تغييرات} many{{count} تغيير} other{{count} تغيير}}'**
  String transfersCount(int count);

  /// No description provided for @fareEgp.
  ///
  /// In ar, this message translates to:
  /// **'{price} جنيه'**
  String fareEgp(String price);

  /// No description provided for @fare.
  ///
  /// In ar, this message translates to:
  /// **'الأجرة'**
  String get fare;

  /// No description provided for @changeTo.
  ///
  /// In ar, this message translates to:
  /// **'غيّر إلى {line} في {station}'**
  String changeTo(String line, String station);

  /// No description provided for @legFromTo.
  ///
  /// In ar, this message translates to:
  /// **'من {from} إلى {to}'**
  String legFromTo(String from, String to);

  /// No description provided for @intermediateStations.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =0{بدون محطات بينية} =1{محطة بينية واحدة} =2{محطتان بينيتان} few{{count} محطات بينية} many{{count} محطة بينية} other{{count} محطة بينية}}'**
  String intermediateStations(int count);

  /// No description provided for @linesTitle.
  ///
  /// In ar, this message translates to:
  /// **'الخطوط والمحطات'**
  String get linesTitle;

  /// No description provided for @branchLabel.
  ///
  /// In ar, this message translates to:
  /// **'{name}'**
  String branchLabel(String name);

  /// No description provided for @stationDetails.
  ///
  /// In ar, this message translates to:
  /// **'المحطة'**
  String get stationDetails;

  /// No description provided for @servesLines.
  ///
  /// In ar, this message translates to:
  /// **'الخطوط التي تخدمها'**
  String get servesLines;

  /// No description provided for @setAsFrom.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ من هنا'**
  String get setAsFrom;

  /// No description provided for @setAsTo.
  ///
  /// In ar, this message translates to:
  /// **'اذهب إلى هنا'**
  String get setAsTo;

  /// No description provided for @libraryTitle.
  ///
  /// In ar, this message translates to:
  /// **'المحفوظات'**
  String get libraryTitle;

  /// No description provided for @favorites.
  ///
  /// In ar, this message translates to:
  /// **'المفضلة'**
  String get favorites;

  /// No description provided for @history.
  ///
  /// In ar, this message translates to:
  /// **'السجل'**
  String get history;

  /// No description provided for @noFavorites.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مسارات مفضلة بعد'**
  String get noFavorites;

  /// No description provided for @noHistory.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد سجل بحث بعد'**
  String get noHistory;

  /// No description provided for @addFavorite.
  ///
  /// In ar, this message translates to:
  /// **'أضف إلى المفضلة'**
  String get addFavorite;

  /// No description provided for @removeFavorite.
  ///
  /// In ar, this message translates to:
  /// **'إزالة من المفضلة'**
  String get removeFavorite;

  /// No description provided for @clearHistory.
  ///
  /// In ar, this message translates to:
  /// **'مسح السجل'**
  String get clearHistory;

  /// No description provided for @clearHistoryConfirm.
  ///
  /// In ar, this message translates to:
  /// **'سيُمسح كل سجل البحث. هل أنت متأكد؟'**
  String get clearHistoryConfirm;

  /// No description provided for @cancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد'**
  String get confirm;

  /// No description provided for @settingsTitle.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get settingsTitle;

  /// No description provided for @language.
  ///
  /// In ar, this message translates to:
  /// **'اللغة'**
  String get language;

  /// No description provided for @arabic.
  ///
  /// In ar, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// No description provided for @english.
  ///
  /// In ar, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @about.
  ///
  /// In ar, this message translates to:
  /// **'عن التطبيق'**
  String get about;

  /// No description provided for @loadError.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر تحميل البيانات'**
  String get loadError;

  /// No description provided for @retry.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get retry;

  /// No description provided for @interchanges.
  ///
  /// In ar, this message translates to:
  /// **'محطات التبديل'**
  String get interchanges;

  /// No description provided for @close.
  ///
  /// In ar, this message translates to:
  /// **'إغلاق'**
  String get close;

  /// No description provided for @versionLabel.
  ///
  /// In ar, this message translates to:
  /// **'الإصدار {version}'**
  String versionLabel(String version);

  /// No description provided for @greetingMorning1.
  ///
  /// In ar, this message translates to:
  /// **'صباح الخير، جاهز للمشوار؟'**
  String get greetingMorning1;

  /// No description provided for @greetingMorning2.
  ///
  /// In ar, this message translates to:
  /// **'صباح النور، فين رايح النهاردة؟'**
  String get greetingMorning2;

  /// No description provided for @greetingMorning3.
  ///
  /// In ar, this message translates to:
  /// **'صباح الفل، مشوارك النهاردة يبدأ من هنا'**
  String get greetingMorning3;

  /// No description provided for @greetingMorning4.
  ///
  /// In ar, this message translates to:
  /// **'صباح الخير، اختار محطتين والباقي علينا'**
  String get greetingMorning4;

  /// No description provided for @greetingAfternoon1.
  ///
  /// In ar, this message translates to:
  /// **'نهارك سعيد، تحب نبدأ منين؟'**
  String get greetingAfternoon1;

  /// No description provided for @greetingAfternoon2.
  ///
  /// In ar, this message translates to:
  /// **'أهلاً بيك، مشوارك على بعد خطوتين'**
  String get greetingAfternoon2;

  /// No description provided for @greetingAfternoon3.
  ///
  /// In ar, this message translates to:
  /// **'نهارك فل، فين محطتك النهاردة؟'**
  String get greetingAfternoon3;

  /// No description provided for @greetingAfternoon4.
  ///
  /// In ar, this message translates to:
  /// **'أهلاً بيك، خلّي المشوار أسهل من كده'**
  String get greetingAfternoon4;

  /// No description provided for @greetingEvening1.
  ///
  /// In ar, this message translates to:
  /// **'مساء الخير، مشوارك تحت إيدك'**
  String get greetingEvening1;

  /// No description provided for @greetingEvening2.
  ///
  /// In ar, this message translates to:
  /// **'مساء الفل، اختار محطتك وخلينا نمشي'**
  String get greetingEvening2;

  /// No description provided for @greetingEvening3.
  ///
  /// In ar, this message translates to:
  /// **'مساء الخير، رايح فين بعد الشغل؟'**
  String get greetingEvening3;

  /// No description provided for @greetingEvening4.
  ///
  /// In ar, this message translates to:
  /// **'مساء النور، خطّط مشوارك في ثانية'**
  String get greetingEvening4;

  /// No description provided for @greetingNight1.
  ///
  /// In ar, this message translates to:
  /// **'سهرة سعيدة، آخر قطار مستنيك'**
  String get greetingNight1;

  /// No description provided for @greetingNight2.
  ///
  /// In ar, this message translates to:
  /// **'لسه صاحي؟ اختار محطتك بسرعة'**
  String get greetingNight2;

  /// No description provided for @greetingNight3.
  ///
  /// In ar, this message translates to:
  /// **'سهرة هادية، فين رايح دلوقتي؟'**
  String get greetingNight3;

  /// No description provided for @greetingNight4.
  ///
  /// In ar, this message translates to:
  /// **'آخر الليل، مشوارك لسه محتاج تخطيط'**
  String get greetingNight4;

  /// No description provided for @dataSnapshotTitle.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ البيانات'**
  String get dataSnapshotTitle;

  /// No description provided for @fareEffectiveTitle.
  ///
  /// In ar, this message translates to:
  /// **'سريان الأجرة'**
  String get fareEffectiveTitle;

  /// No description provided for @planTrip.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ رحلة'**
  String get planTrip;

  /// No description provided for @changeAt.
  ///
  /// In ar, this message translates to:
  /// **'غيّر الخط في {station}'**
  String changeAt(String station);

  /// No description provided for @onboardingTitle.
  ///
  /// In ar, this message translates to:
  /// **'أهلاً بيك في معاك'**
  String get onboardingTitle;

  /// No description provided for @onboardingBody.
  ///
  /// In ar, this message translates to:
  /// **'اختار اللغة والمظهر، وتقدر تغيّرهم في أي وقت من الإعدادات.'**
  String get onboardingBody;

  /// No description provided for @onboardingStart.
  ///
  /// In ar, this message translates to:
  /// **'يلا نبدأ'**
  String get onboardingStart;

  /// No description provided for @appearance.
  ///
  /// In ar, this message translates to:
  /// **'المظهر'**
  String get appearance;

  /// No description provided for @themeSystem.
  ///
  /// In ar, this message translates to:
  /// **'النظام'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In ar, this message translates to:
  /// **'فاتح'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In ar, this message translates to:
  /// **'غامق'**
  String get themeDark;

  /// No description provided for @removeFromHistory.
  ///
  /// In ar, this message translates to:
  /// **'إزالة من السجل'**
  String get removeFromHistory;

  /// No description provided for @estimatedLabel.
  ///
  /// In ar, this message translates to:
  /// **'الوقت التقديري'**
  String get estimatedLabel;

  /// No description provided for @minutesShort.
  ///
  /// In ar, this message translates to:
  /// **'دقيقة'**
  String get minutesShort;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
