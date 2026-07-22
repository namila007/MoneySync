import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/core/crypto/keyed_hmac.dart';

void main() {
  test(
    'HMAC input copies valid bytes and does not retain caller mutability',
    () {
      final source = <int>[0, 127, 255];
      final input = HmacInput(source);
      source[0] = 99;

      expect(input.bytes, [0, 127, 255]);
      expect(() => input.bytes[0] = 1, throwsUnsupportedError);
    },
  );

  test('HMAC input rejects non-byte values', () {
    expect(() => HmacInput([-1]), throwsArgumentError);
    expect(() => HmacInput([256]), throwsArgumentError);
  });

  test('digest accepts exactly 64 lowercase hexadecimal characters', () {
    const valid =
        'abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789';

    expect(HmacDigest(valid).hex, valid);
    expect(() => HmacDigest(valid.toUpperCase()), throwsArgumentError);
    expect(() => HmacDigest(valid.substring(1)), throwsArgumentError);
    expect(() => HmacDigest('${valid}0'), throwsArgumentError);
  });
}
