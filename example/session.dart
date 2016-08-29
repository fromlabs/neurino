// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:neurino/neurino.dart';

main() {
  // model graph
  var k = new Constant(1, id: "k");
  var x1 = new Input(id: "x");
  var w1 = new Variable();
  var b1 = new Variable();

  var mul1 = new Mul(x1, w1);
  var yPredicted1 = new Add(mul1, b1);
  var yReal1 = new Input();
  var loss1 = new Loss1(yPredicted1, yReal1);

  var initVariables = new Batch([
    new VariableUpdate(w1, 1),
    new VariableUpdate(b1, 0)
  ]);

  // model session

  var session = new Session();

  try {
    print(session[k]);

    throw new AssertionError();
  } on StateError {
    // pass
  }

  try {
    print(session.run(x1, inputs: {yReal1: 5}));

    throw new AssertionError();
  } on StateError {
    // pass
  }

  try {
    print(session.run(loss1, inputs: {yReal1: 5}));

    throw new AssertionError();
  } on StateError {
    // pass
  }

  try {
    print(session.run(loss1, inputs: {x1: -2, yReal1: 5}));

    throw new AssertionError();
  } on StateError {
    // pass
  }

  try {
    print(session[w1]);

    throw new AssertionError();
  } on StateError {
    // pass
  }

  print(session.run(x1, inputs: {x1: -2, yReal1: 5}));

  try {
    print(session[w1]);

    throw new AssertionError();
  } on StateError {
    // pass
  }

  print(session.run(initVariables));
  print(session[w1]);

  print(session.run(loss1, inputs: {x1: -2, yReal1: 5}));
  print(session[loss1]);
  print(session[yReal1]);
  print(session[yPredicted1]);
  print(session[mul1]);
  print(session[b1]);
  print(session[w1]);
  print(session[x1]);
  print(session[k]);
}
