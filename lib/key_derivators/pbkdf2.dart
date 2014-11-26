// Copyright (c) 2013-present, Iván Zaera Avellón - izaera@gmail.com

// This library is dually licensed under LGPL 3 and MPL 2.0. See file LICENSE for more information.

// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of
// the MPL was not distributed with this file, you can obtain one at http://mozilla.org/MPL/2.0/.

library cipher.key_derivators.pbkdf2;

import "dart:typed_data";

import "package:cipher/api.dart";
import "package:cipher/key_derivators/api.dart";
import "package:cipher/key_derivators/base_key_derivator.dart";

/**
 * Generator for PBE derived keys and ivs as defined by PKCS 5 V2.0 Scheme 2. This generator uses a
 * SHA-1 HMac as the calculation function. The document this implementation is based on can be found
 * at:
 *
 * * [http://www.rsasecurity.com/rsalabs/pkcs/pkcs-5/index.html]
 *
 */
class PBKDF2KeyDerivator extends BaseKeyDerivator {

  final Mac _mac;

  final List<int> _salt;
  final int _iterationCount;
  final int _desiredKeyLength;

  Uint8List _state;

  PBKDF2KeyDerivator(Map<Param, dynamic> params, Mac mac)
      : super("${mac.algorithmName}/PBKDF2", params),
        _mac = mac,
        _desiredKeyLength = params[Param.DesiredKeyLength],
        _salt = params[Param.Salt],
        _iterationCount = params[Pbkdf2Param.IterationCount] {

    _state = new Uint8List(_mac.macSize);

    reset();
  }

  int get keySize => _desiredKeyLength;

  void reset() {
    _mac.reset();

    _state.fillRange(0, _state.length, 0);
  }

  int deriveKey(Uint8List inp, int inpOff, Uint8List out, int outOff) {
    var dkLen = _desiredKeyLength;
    var hLen = _mac.macSize;
    var l = (dkLen + hLen - 1) ~/ hLen;
    var iBuf = new Uint8List(4);
    var outBytes = new Uint8List(l * hLen);
    var outPos = 0;

    CipherParameters param = new KeyParameter(inp.sublist(inpOff));
    _mac.init(param);

    for (var i = 1; i <= l; i++) {
      // Increment the value in 'iBuf'
      var pos = 3;
      for (var pos = 3; ; pos--) {
        iBuf[pos]++;
        if (iBuf[pos] != 0) break;
      }

      _F(_salt, _iterationCount, iBuf, outBytes, outPos);
      outPos += hLen;
    }

    out.setRange(outOff, outOff + dkLen, outBytes);

    return keySize;
  }

  void _F(Uint8List S, int c, Uint8List iBuf, Uint8List out, int outOff) {
    if (c <= 0) {
      throw new ArgumentError("Iteration count must be at least 1.");
    }

    if (S != null) {
      _mac.update(S, 0, S.length);
    }

    _mac.update(iBuf, 0, iBuf.length);
    _mac.doFinal(_state, 0);

    out.setRange(outOff, outOff + _state.length, _state);

    for (var count = 1; count < c; count++) {
      _mac.update(_state, 0, _state.length);
      _mac.doFinal(_state, 0);

      for (var j = 0; j != _state.length; j++) {
        out[outOff + j] ^= _state[j];
      }
    }
  }

}
