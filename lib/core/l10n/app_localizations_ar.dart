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
  String dataSnapshot(String date) {
    return 'تاريخ البيانات $date';
  }

  @override
  String fareEffective(String date) {
    return 'سريان الأجرة $date';
  }

  @override
  String get loadError => 'تعذّر تحميل البيانات';

  @override
  String get retry => 'إعادة المحاولة';
}
