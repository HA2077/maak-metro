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

  test('no match returns an empty list', () {
    expect(_search('zzz'), isEmpty);
  });
}
