// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:test/test.dart';

import "package:neurino/neurino.dart";

void main() {
  group('Quantity Tests', () {
    test('1', () {
      var s1 = new Scalar(1.0);
      print(s1);

      // VECTOR

      var v1 = new Vector([1.0, 3.0]);
      print(v1);

      var v2 = new Vector.filled(3, 0.0);
      print(v2);

      var v3 = new Vector.generate(3, (index) => index + 1.0);
      print(v3);

      // MATRIX

      var m1 = new Matrix([
        [1.0, 2.0],
        [3.0, 4.0]
      ]);
      print(m1);

      expect(
          () => new Matrix([
                [
                  [1.0],
                  [2.0]
                ],
                [
                  [3.0],
                  [4.0]
                ],
                [
                  [3.0],
                  [4.0, 1.0]
                ]
              ]),
          throwsArgumentError);

      var m2 = new Matrix.filled([2, 2], 0.0);
      print(m2);

      var m3 = new Matrix.generate(
          [2, 2], (indices) => (indices[0] + 1) * 10 + (indices[1] + 1.0));
      print(m3);
    });
  });
}
