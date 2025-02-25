import 'package:prudapp/string_api.dart';
import 'package:test/test.dart';


void main() {
  group('dart_extensions', () {

    test('string_containsAny', () {
      final String str = "I love YAHUAH";
      print("${DateTime.now()}");
      bool exist = str.containsAny(["YAHUSHA", "YAHUAH"]);
      print("${DateTime.now()}");
      expect(exist, false);
    });
  });
}