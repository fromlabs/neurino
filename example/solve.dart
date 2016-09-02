// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:test/test.dart';

import "package:neurino/neurino.dart";

const int STEPS = 10;
const num DX = 0.01;

void main() {
  // SOLVE EQUATION
  // y = 5 * x^2 + 3 * x - 2

  const a = 5;
  const b = 3;
  const c = -2;

  var f = (num x) => a * x * x + b * x + c;

  var xNode = new ModelInput(id: "x");
  var yRealNode = new ModelInput(id: "y_real");

  var aNode = new Variable(() => 0, id: "a");
  var bNode = new Variable(() => 0, id: "b");
  var cNode = new Variable(() => 0, id: "c");

  var yNode = new Add(
      new Add(new Mul(aNode, new Mul(xNode, xNode)), new Mul(bNode, xNode)),
      cNode,
      id: "y");

  var lossNode = new Loss2(yNode, yRealNode, id: "loss");

  var optimizerNode =
      new GradientsEvaluate(lossNode, learningRate: 0.0001, id: "optimizer");

  new Session().asDefault((session) {
    session.run(new AllVariablesInitialize());

    for (var i = 0; i < STEPS; i++) {
      for (var x = -10; x <= 10; x += DX) {
        var yReal = f(x);

        session.run(optimizerNode, inputs: {xNode: x, yRealNode: yReal});

        // print("f($x) = ${yNode.evaluation} [$yReal]");
        // print("loss: ${lossNode.evaluation}");
      }

      print("******* STEP $i *******");
      print("a = ${aNode.evaluation} [$a]");
      print("b = ${bNode.evaluation} [$b]");
      print("c = ${cNode.evaluation} [$c]");
    }
  });
}
