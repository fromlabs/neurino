// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:neurino/neurino.dart';

import "dart:async";

main() {
  // model graph

  var model = new ModelDescriptor();

  var xInput = model.register(new PlaceHolder());
  var yInput = model.register(new PlaceHolder());
  var zInput = model.register(new PlaceHolder());

  var add = model.register(new Add(xInput, yInput));
  var mul = model.register(new Mul(add, zInput));

  // model session

  var session = new ModelSession(model);

  // evaluation
  var mulValue = session.run(mul, {xInput: -2, yInput: 5, zInput: -4});

  print(mulValue);

  print(session.getEvaluation(xInput));
  print(session.getEvaluation(yInput));
  print(session.getEvaluation(zInput));
  print(session.getEvaluation(add));
  print(session.getEvaluation(mul));

  // TODO implementare le variabili
}
