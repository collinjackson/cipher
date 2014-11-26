// Copyright (c) 2013-present, Iván Zaera Avellón - izaera@gmail.com

// This library is dually licensed under LGPL 3 and MPL 2.0. See file LICENSE for more information.

// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of
// the MPL was not distributed with this file, you can obtain one at http://mozilla.org/MPL/2.0/.

library cipher.test.test.stream_cipher_tests;

import "dart:typed_data";

import "package:cipher/cipher.dart";
import "package:unittest/unittest.dart";

import "./src/helpers.dart";

void runStreamCipherTests(String algorithmName, Map<Param, dynamic> params,
    List<String> plainCipherTextPairs) {

  final cipher = new StreamCipher(algorithmName, <Param, dynamic>{}
      ..[Param.ForEncryption] = true
      ..addAll(params));

  final decipher = new StreamCipher(algorithmName, <Param, dynamic>{}
      ..[Param.ForEncryption] = false
      ..addAll(params));


  group("${algorithmName}:", () {

    group("cipher  :", () {
      for (var i = 0; i < plainCipherTextPairs.length; i += 2) {

        var plainText = plainCipherTextPairs[i];
        var cipherText = plainCipherTextPairs[i + 1];

        test(
            "${formatAsTruncated(plainText)}",
            () => _runStreamCipherTest(cipher, plainText, cipherText));

      }
    });

    group("decipher:", () {
      for (var i = 0; i < plainCipherTextPairs.length; i += 2) {

        var plainText = plainCipherTextPairs[i];
        var cipherText = plainCipherTextPairs[i + 1];

        test(
            "${formatAsTruncated(plainText)}",
            () => _runStreamDecipherTest(decipher, cipherText, plainText));

      }
    });

    group("ciph&dec:", () {
      var plainText = createUint8ListFromSequentialNumbers(1021);

      test(
          "~1KB of sequential bytes",
          () => _runStreamCipherDecipherTest(cipher, decipher, plainText));

    });

  });

}

void _runStreamCipherTest(StreamCipher cipher, String plainTextString, String expectedHexCipherText)
    {

  cipher.reset();

  var plainText = createUint8ListFromString(plainTextString);
  var cipherText = cipher.process(plainText);
  var hexCipherText = formatBytesAsHexString(cipherText);

  expect(hexCipherText, equals(expectedHexCipherText));
}

void _runStreamDecipherTest(StreamCipher decipher, String hexCipherText, String expectedPlainText) {
  decipher.reset();

  var cipherText = createUint8ListFromHexString(hexCipherText);
  var plainText = decipher.process(cipherText);

  expect(new String.fromCharCodes(plainText), equals(expectedPlainText));
}

void _runStreamCipherDecipherTest(StreamCipher cipher, StreamCipher decipher, Uint8List plainText) {
  cipher.reset();
  var cipherText = cipher.process(plainText);

  decipher.reset();
  var plainTextAgain = decipher.process(cipherText);

  expect(plainTextAgain, equals(plainText));
}
