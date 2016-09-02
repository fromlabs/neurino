// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

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
        var w = new Variable(() => 0);
        var b = new Variable(() => 0);
        var mul = new Mul(w, x, id: "mul");
        var add = new Add(mul, b, id: "add");
        new Negate(add, id: "y");
      });
    });

    test('3', () {
      new Model().asDefault(() {
        var x = new ModelInput();
        var w = new Variable(() => 0);
        var b = new Variable(() => 0);
        var composite = new Composite({"x": x, "w": w, "b": b},
            (inputs) => new Add(new Mul(inputs[w], inputs[x]), inputs[b]),
            id: "composite");
        new Negate(composite, id: "y");
      });
    });

    test('4', () {
      new Model().asDefault(() {
        var x = new ModelInput();
        var composite = new Composite({"x": x}, (inputs) {
          var w = new Variable(() => 0);
          var b = new Variable(() => 0);

          expect(() => new Negate(x), throwsArgumentError);

          return new Add(new Mul(w, inputs[x]), b);
        });
        new Negate(composite, id: "y");
      });
    });
  });
}
