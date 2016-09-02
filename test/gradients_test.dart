// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:test/test.dart';

import "package:neurino/neurino.dart";

void main() {
  group('Model Tests', () {
    test('1', () {
      var x;
      var w;
      var b;
      var y;

      var model = new Model()
        ..asDefault(() {
          x = new ModelInput(id: "x");
          w = new Variable(() => 1, id: "w");
          b = new Variable(() => 2, id: "b");
          var mul = new Mul(w, x, id: "mul");
          var add = new Add(mul, b, id: "add");
          y = new Negate(add, id: "y");
        });

      var session = new Session(model);
      session.asDefault(() {
        session.run(new AllVariablesInitialize());

        session.run(new GradientsEvaluate(y), inputs: {x: 1});
      });
    });

    test('2', () {
      var x;
      var y;
      var z;
      var f;

      var model = new Model()
        ..asDefault(() {
          x = new ModelInput(id: "x");
          y = new ModelInput(id: "y");
          z = new ModelInput(id: "z");
          var q = new Add(x, y, id: "q");
          f = new Mul(q, z, id: "f");
        });

      var session = new Session(model);
      session.asDefault(() {
        session.run(new GradientsEvaluate(f), inputs: {x: -2, y: 5, z: -4});
      });
    });

    test('3', () {
      var w0;
      var x0;
      var w1;
      var x1;
      var w2;
      var inv;

      var model = new Model()
        ..asDefault(() {
          w0 = new ModelInput(id: "w0");
          x0 = new ModelInput(id: "x0");
          w1 = new ModelInput(id: "w1");
          x1 = new ModelInput(id: "x1");
          w2 = new ModelInput(id: "w2");
          var mul0 = new Mul(w0, x0, id: "mul0");
          var mul1 = new Mul(w1, x1, id: "mul1");
          var add0 = new Add(mul0, mul1, id: "add0");
          var add1 = new Add(add0, w2, id: "add1");
          var neg = new Negate(add1, id: "neg");
          var exp = new Exp(neg, id: "exp");
          var inc = new Add(exp, 1, id: "inc");
          inv = new Div(1, inc, id: "inv");
        });

      var session = new Session(model);
      session.asDefault(() {
        session.run(new GradientsEvaluate(inv),
            inputs: {w0: 2, x0: -1, w1: -3, x1: -2, w2: -3});

        print(inv.evaluation);
      });
    });

    test('4', () {
      var w0;
      var x0;
      var w1;
      var x1;
      var w2;
      var inv;

      var model = new Model()
        ..asDefault(() {
          w0 = new ModelInput(id: "w0");
          x0 = new ModelInput(id: "x0");
          w1 = new ModelInput(id: "w1");
          x1 = new ModelInput(id: "x1");
          w2 = new ModelInput(id: "w2");

          var composite = new Composite(
              {"w0": w0, "x0": x0, "w1": w1, "x1": x1, "w2": w2}, (inputs) {
            var mul0 = new Mul(inputs[w0], inputs[x0], id: "mul0");
            var mul1 = new Mul(inputs[w1], inputs[x1], id: "mul1");
            var add0 = new Add(mul0, mul1, id: "add0");
            var add1 = new Add(add0, inputs[w2], id: "add1");
            var neg = new Negate(add1, id: "neg");
            var exp = new Exp(neg, id: "exp");
            return new Add(exp, 1, id: "inc");
          }, id: "composite");

          inv = new Div(1, composite, id: "inv");
        });

      var session = new Session(model);
      session.asDefault(() {
        session.run(new GradientsEvaluate(inv),
            inputs: {w0: 2, x0: -1, w1: -3, x1: -2, w2: -3});

        print(inv.evaluation);
      });
    });
  });
}
