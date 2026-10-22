import 'package:flutter_test/flutter_test.dart';
import 'package:panjang_umur_frontend/core/models/user.dart';

void main() {
  Gender parse(Object? gender) =>
      User.fromJson({'id': '1', 'name': 'n', 'username': 'u', 'gender': gender}).gender;

  test('parses gender, falling back to unspecified', () {
    expect(parse(1), Gender.male);
    expect(parse(2), Gender.female);
    expect(parse(0), Gender.unspecified);
    expect(parse(null), Gender.unspecified);
    expect(parse(9), Gender.unspecified);
  });
}
