import 'package:flutter_test/flutter_test.dart';
import 'package:maak_metro/core/utils/station_search.dart';
import 'package:maak_metro/domain/models/metro_models.dart';

const _stations = [
  Station(id: 'sadat', nameAr: 'السادات', nameEn: 'Sadat'),
  Station(id: 'sadat_station', nameAr: 'محطة السادات', nameEn: 'Sadat Station'),
  Station(id: 'shohadaa', nameAr: 'الشهداء', nameEn: 'Al-Shohadaa'),
  Station(id: 'kit_kat', nameAr: 'الكيت كات', nameEn: 'Kit Kat'),
];

List<Station> _search(String query) => searchStations(
  _stations,
  query,
  name: (station) => station.nameAr,
  otherName: (station) => station.nameEn,
);

void main() {
  test('an empty query keeps every station in data order', () {
    expect(_search('').map((s) => s.id), _stations.map((s) => s.id));
  });

  test('exact match ranks before prefix and contains', () {
    expect(_search('السادات').first.id, 'sadat');
  });

  test('hamza and ta marbuta variants still find the station', () {
    expect(_search('الكيت كات').map((s) => s.id), contains('kit_kat'));
    expect(_search('الشهدا').map((s) => s.id), ['shohadaa']);
  });

  test('the other language name is searched too', () {
    expect(_search('kit').map((s) => s.id), ['kit_kat']);
    expect(_search('sadat').first.id, 'sadat');
  });

  test('one typo still finds the station', () {
    expect(_search('الكيت كت').map((s) => s.id), contains('kit_kat'));
    expect(_search('السادت').map((s) => s.id), contains('sadat'));
  });

  test('an exact match still ranks first', () {
    expect(_search('السادات').first.id, 'sadat');
    expect(_search('الشهداء').first.id, 'shohadaa');
  });

  test('no match returns an empty list', () {
    expect(_search('zzz'), isEmpty);
  });

  group('common spellings of hard station names', () {
    const stations = [
      Station(id: 'shohadaa', nameAr: 'الشهداء', nameEn: 'Al-Shohadaa'),
      Station(id: 'imbaba', nameAr: 'إمبابة', nameEn: 'Imbaba'),
      Station(id: 'kit_kat', nameAr: 'الكيت كات', nameEn: 'Kit Kat'),
      Station(id: 'uni', nameAr: 'جامعة القاهرة', nameEn: 'Cairo University'),
      Station(
        id: 'arab_league',
        nameAr: 'جامعة الدول العربية',
        nameEn: 'Arab League',
      ),
      Station(id: 'naguib', nameAr: 'محمد نجيب', nameEn: 'Mohamed Naguib'),
      Station(id: 'attaba', nameAr: 'العتبة', nameEn: 'Attaba'),
    ];

    List<Station> search(String query) => searchStations(
      stations,
      query,
      name: (station) => station.nameAr,
      otherName: (station) => station.nameEn,
    );

    const variants = {
      // dropped final hamza
      'الشهدا': 'shohadaa',
      // alef without hamza, ta marbuta written as ha
      'امبابه': 'imbaba',
      // missing space
      'الكيتكات': 'kit_kat',
      // both words respelled
      'جامعه القاهره': 'uni',
      // one wrong letter
      'محمد نحيب': 'naguib',
    };

    for (final entry in variants.entries) {
      test('"${entry.key}" finds ${entry.value}', () {
        expect(search(entry.key).first.id, entry.value);
      });
    }

    test('the exact name still comes first', () {
      expect(search('الشهداء').first.id, 'shohadaa');
      expect(search('جامعة القاهرة').map((s) => s.id), ['uni']);
      expect(
        search('جامعة').map((s) => s.id),
        containsAll(<String>['uni', 'arab_league']),
      );
    });
  });
}
