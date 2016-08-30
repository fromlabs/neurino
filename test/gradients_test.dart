// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import "dart:async";

import 'package:test/test.dart';

import "package:neurino/neurino.dart";

void main() {
  group('Model Tests', () {
    test('1', () {
      var k = new Constant(1);

      expect(k.evaluation, 1);

      var session = new Session();
      session.asDefault(() {
        expect(k.evaluation, 1);

        expect(session.run(k), 1);
      });
    });

    test('2', () {
      var x = new ModelInput();

      expect(x.isEvaluated, false);
      expect(() => x.evaluation, throwsStateError);

      var session = new Session();
      session.asDefault(() {
        expect(x.isEvaluated, false);
        expect(() => x.evaluation, throwsStateError);

        expect(() => session.run(x), throwsStateError);

        expect(session.run(x, inputs: {x: 2}), 2);
        expect(x.evaluation, 2);

        expect(session.run(x, inputs: {x: 3}), 3);
        expect(x.evaluation, 3);
      });
    });

    test('3', () {
      var x = new Variable(() => 4);

      var initX = new AllVariableInitialize();

      expect(x.isEvaluated, false);
      expect(() => x.evaluation, throwsStateError);
      expect(initX.isEvaluated, false);
      expect(() => initX.evaluation, throwsStateError);

      var session = new Session();
      session.asDefault(() {
        expect(x.isEvaluated, false);
        expect(() => x.evaluation, throwsStateError);
        expect(initX.isEvaluated, false);
        expect(() => initX.evaluation, throwsStateError);

        expect(() => session.run(x), throwsStateError);

        expect(session.run(initX), true);

        expect(x.isEvaluated, true);
        expect(initX.isEvaluated, true);

        expect(x.evaluation, 4);

        expect(session.run(x), 4);

        expect(session.run(initX), true);

        expect(session.run(new Batch([initX])), [true]);
        expect(session.run(new Batch([new VariableUpdate(x, 5)])), [true]);

        expect(session.run(x), 5);

        expect(
            () => session.run(new Batch(
                [new VariableUpdate(x, 6), new VariableUpdate(x, 7)])),
            throwsStateError);

        expect(session.run(x), 5);
      });
    });

    test('4', () {
      var y = new Add(5, new Constant(4));

      var session = new Session();
      session.asDefault(() {
        expect(session.run(y), 9);
        expect(y.evaluation, 9);
      });
    });

    test('5', () {
      var x;
      var w;
      var b;
      var y;

      var model = new Model()
        ..asDefault(() {
          x = new ModelInput();
          w = new Variable(() => 1);
          b = new Variable(() => 2);
          var mul = new Mul(w, x, id: "mul");
          var add = new Add(mul, b, id: "add");
          y = new Negate(add, id: "y");
        });

      var session = new Session(model);
      session.asDefault(() {
        session.run(new AllVariableInitialize());

        expect(session.run(y, inputs: {x: 5}), -7);
        expect(y.evaluation, -7);
      });
    });

    test('6', () {
      var x;
      var w;
      var b;
      var y;

      var model = new Model()
        ..asDefault(() {
          x = new ModelInput();
          w = new Variable(() => 1);
          b = new Variable(() => 2);
          var composite = new Composite({"x": x, "w": w, "b": b},
              (inputs) => new Add(new Mul(inputs[w], inputs[x]), inputs[b]));
          y = new Negate(composite, id: "y");
        });

      var session = new Session(model);
      session.asDefault(() {
        session.run(new AllVariableInitialize());

        expect(session.run(y, inputs: {x: 5}), -7);
        expect(y.evaluation, -7);
      });
    });

    test('7', () {
      var x;
      var w;
      var b;
      var y;

      var model = new Model()
        ..asDefault(() {
          x = new ModelInput();
          var composite = new Composite({"x": x}, (parentInputs) {
            var w = new Variable(() => 1);
            var b = new Variable(() => 2);

            expect(() => new Negate(x), throwsArgumentError);

            return new Add(new Mul(w, parentInputs[x]), b);
          });
          y = new Negate(composite, id: "y");
        });

      var session = new Session(model);
      session.asDefault(() {
        expect(session.run(new AllVariableInitialize()), true);
        expect(session.run(y, inputs: {x: 5}), -7);
        expect(y.evaluation, -7);
      });
    });
  });
}
