// Copyright (c) 2013-present, Iván Zaera Avellón - izaera@gmail.com

// This library is dually licensed under LGPL 3 and MPL 2.0. See file LICENSE for more information.

// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of
// the MPL was not distributed with this file, you can obtain one at http://mozilla.org/MPL/2.0/.

library cipher.paddings.pkcs7;

import "dart:typed_data";

import "package:cipher/api.dart";
import "package:cipher/src/ufixnum.dart";
import "package:cipher/paddings/base_padding.dart";

/// A [Padding] that adds PKCS7/PKCS5 padding to a block.
class PKCS7Padding extends BasePadding {

  PKCS7Padding(Map<Param, dynamic> params)
      : super("PKCS7", params);

  void addPadding(Uint8List data, int padOffset) {
    var code = (data.length - padOffset);

    while (padOffset < data.length) {
      data[padOffset] = code;
      padOffset++;
    }
  }

  int countPadding(Uint8List data) {
    var count = clip8(data[data.length - 1]);

    if (count > data.length || count == 0) {
      throw new ArgumentError("Invalid or corrupted pad block");
    }

    for (var i = 1; i <= count; i++) {
      if (data[data.length - i] != count) {
        throw new ArgumentError("Invalid or corrupted pad block");
      }
    }

    return count;
  }

}
