// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'معاك';

  @override
  String get tabPlanner => 'التخطيط';

  @override
  String get tabLines => 'الخطوط';

  @override
  String get tabLibrary => 'محفوظات';

  @override
  String get tabSettings => 'الإعدادات';

  @override
  String get plannerTitle => 'خطّط مشوارك';

  @override
  String get plannerHint => 'اختر محطتي البداية والنهاية لعرض أفضل مسار';

  @override
  String get fromLabel => 'من';

  @override
  String get toLabel => 'إلى';

  @override
  String get selectStation => 'اختر محطة';

  @override
  String get searchStations => 'ابحث باسم المحطة';

  @override
  String get noStationsFound => 'لا توجد محطة بهذا الاسم';

  @override
  String get swapStations => 'تبديل المحطتين';

  @override
  String get findRoute => 'اعرض المسار';

  @override
  String get sameStationError => 'محطة البداية والنهاية واحدة';

  @override
  String get noRouteError => 'لا يوجد مسار بين المحطتين';

  @override
  String get recentSearches => 'آخر عمليات البحث';

  @override
  String get interchanges => 'محطات التبديل';

  @override
  String get noData => 'بيانات الشبكة لم تُحمَّل بعد';

  @override
  String get routeTitle => 'المسار';

  @override
  String estimatedTime(String minutes) {
    return 'الوقت التقديري $minutes دقيقة';
  }

  @override
  String stationsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count محطة',
      many: '$count محطة',
      few: '$count محطات',
      two: 'محطتان',
      one: 'محطة واحدة',
      zero: 'لا محطات',
    );
    return '$_temp0';
  }

  @override
  String transfersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count تغيير',
      many: '$count تغيير',
      few: '$count تغييرات',
      two: 'تغييران',
      one: 'تغيير واحد',
      zero: 'بدون تغيير خط',
    );
    return '$_temp0';
  }

  @override
  String fareEgp(String price) {
    return '$price جنيه';
  }

  @override
  String changeAt(String station) {
    return 'غيّر الخط في $station';
  }

  @override
  String legFromTo(String from, String to) {
    return 'من $from إلى $to';
  }

  @override
  String intermediateStations(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count محطة بينية',
      many: '$count محطة بينية',
      few: '$count محطات بينية',
      two: 'محطتان بينيتان',
      one: 'محطة بينية واحدة',
      zero: 'بدون محطات بينية',
    );
    return '$_temp0';
  }

  @override
  String get linesTitle => 'الخطوط والمحطات';

  @override
  String branchLabel(String name) {
    return '$name';
  }

  @override
  String get stationDetails => 'المحطة';

  @override
  String get servesLines => 'الخطوط التي تخدمها';

  @override
  String get setAsFrom => 'ابدأ من هنا';

  @override
  String get setAsTo => 'اذهب إلى هنا';

  @override
  String get libraryTitle => 'المحفوظات';

  @override
  String get favorites => 'المفضلة';

  @override
  String get history => 'السجل';

  @override
  String get noFavorites => 'لا توجد مسارات مفضلة بعد';

  @override
  String get noHistory => 'لا يوجد سجل بحث بعد';

  @override
  String get addFavorite => 'أضف إلى المفضلة';

  @override
  String get removeFavorite => 'إزالة من المفضلة';

  @override
  String get clearHistory => 'مسح السجل';

  @override
  String get clearHistoryConfirm => 'سيُمسح كل سجل البحث. هل أنت متأكد؟';

  @override
  String get cancel => 'إلغاء';

  @override
  String get confirm => 'تأكيد';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get language => 'اللغة';

  @override
  String get appearance => 'المظهر';

  @override
  String get themeSystem => 'حسب النظام';

  @override
  String get themeLight => 'فاتح';

  @override
  String get themeDark => 'غامق';

  @override
  String get planTrip => 'ابدأ رحلة';

  @override
  String get close => 'إغلاق';

  @override
  String get arabic => 'العربية';

  @override
  String get english => 'English';

  @override
  String get about => 'عن التطبيق';

  @override
  String get dataSnapshot => 'تاريخ البيانات';

  @override
  String get fareEffective => 'سريان الأجرة';

  @override
  String get loadError => 'تعذّر تحميل البيانات';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String versionLabel(String version) {
    return 'الإصدار $version';
  }

  @override
  String get onboardingTitle => 'أهلاً بيك في معاك';

  @override
  String get onboardingBody =>
      'اختار اللغة والمظهر، وتقدر تغيّرهم في أي وقت من الإعدادات.';

  @override
  String get onboardingStart => 'يلا نبدأ';

  @override
  String get greetingMorning1 => 'صباح الخير، جاهز للمشوار؟';

  @override
  String get greetingMorning2 => 'صباح النور، فين رايح النهاردة؟';

  @override
  String get greetingAfternoon1 => 'نهارك سعيد، تحب نبدأ منين؟';

  @override
  String get greetingAfternoon2 => 'أهلاً بيك، مشوارك على بعد خطوتين';

  @override
  String get greetingEvening1 => 'مساء الخير، مشوارك تحت إيدك';

  @override
  String get greetingEvening2 => 'مساء الفل، اختار محطتك وخلينا نمشي';

  @override
  String get greetingNight1 => 'سهرة سعيدة، آخر قطار مستنيك';

  @override
  String get greetingNight2 => 'لسه صاحي؟ اختار محطتك بسرعة';

  @override
  String get greetingMorning3 => 'صباح الفل، مشوارك النهاردة يبدأ من هنا';

  @override
  String get greetingMorning4 => 'صباح الخير، اختار محطتين والباقي علينا';

  @override
  String get greetingAfternoon3 => 'نهارك فل، فين محطتك النهاردة؟';

  @override
  String get greetingAfternoon4 => 'أهلاً بيك، خلّي المشوار أسهل من كده';

  @override
  String get greetingEvening3 => 'مساء الخير، رايح فين بعد الشغل؟';

  @override
  String get greetingEvening4 => 'مساء النور، خطّط مشوارك في ثانية';

  @override
  String get greetingNight3 => 'سهرة هادية، فين رايح دلوقتي؟';

  @override
  String get greetingNight4 => 'آخر الليل، مشوارك لسه محتاج تخطيط';

  @override
  String get dateFormat => 'تنسيق التاريخ';

  @override
  String get dateNumeric => 'رقمي';

  @override
  String get dateWritten => 'مكتوب';

  @override
  String get monthJan => 'يناير';

  @override
  String get monthFeb => 'فبراير';

  @override
  String get monthMar => 'مارس';

  @override
  String get monthApr => 'أبريل';

  @override
  String get monthMay => 'مايو';

  @override
  String get monthJun => 'يونيو';

  @override
  String get monthJul => 'يوليو';

  @override
  String get monthAug => 'أغسطس';

  @override
  String get monthSep => 'سبتمبر';

  @override
  String get monthOct => 'أكتوبر';

  @override
  String get monthNov => 'نوفمبر';

  @override
  String get monthDec => 'ديسمبر';
}
