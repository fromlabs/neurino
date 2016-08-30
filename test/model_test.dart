// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import "dart:async";

import 'package:test/test.dart';

import "package:neurino/neurino.dart";

void main() {
  group('Model Tests', () {
    test('1', () {
      expect(new Constant(0).id, "constant/0");
      expect(new Constant(0).id, "constant/1");
      expect(new Constant(0, id: "k").id, "k");

      new Model().asDefault(() {
        expect(new Constant(0).id, "constant/0");
        expect(new Constant(0).id, "constant/1");
        expect(new Constant(0, id: "k").id, "k");
      });

      expect(new Constant(0).id, "constant/2");

      expect(() => new Constant(0, id: "k"), throwsArgumentError);
    });

    test('2', () {
      new Model().asDefault(() {
        var x = new ModelInput();
        var w = new Variable();
        var b = new Variable();
        var mul = new Mul(w, x, id: "mul");
        var add = new Add(mul, b, id: "add");
        var y = new Negate(add, id: "y");

        print(y);
      });
    });

    test('3', () {
      new Model().asDefault(() {
        var x = new ModelInput();
        var w = new Variable();
        var b = new Variable();
        var composite = new Composite(
            {"x": x, "w": w, "b": b},
            (parentInputs) => new Add(
                new Mul(parentInputs[w], parentInputs[x]), parentInputs[b]),
            id: "composite");
        var y = new Negate(composite, id: "y");

        print(y);
      });
    });

    test('4', () {
      new Model().asDefault(() {
        var x = new ModelInput();
        var composite = new Composite({"x": x}, (parentInputs) {
          var w = new Variable();
          var b = new Variable();

          expect(() => new Negate(x), throwsArgumentError);

          return new Add(new Mul(w, parentInputs[x]), b);
        });
        var y = new Negate(composite, id: "y");

        print(y);
      });
    });
  });
}
