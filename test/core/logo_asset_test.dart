import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('logo asset is bundled', () async {
    final data = await rootBundle.load('assets/images/logo.webp');
    expect(data.lengthInBytes, greaterThan(1000));
  });
}
