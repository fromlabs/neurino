// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:neurino/neurino.dart';

main() {
  // model graph

  var model = new ModelDescriptor();

  var xInput = model.registerNode(new Input());
  var yInput = model.registerNode(new Input());
  var zInput = model.registerNode(new Input());

  var add = model.registerNode(new Add(xInput, yInput));
  var mul = model.registerNode(new Mul(add, zInput));

  // model session

  var session = new Session(model);

  // evaluation
  var mulValue = session.run(mul, inputs: {xInput: -2, yInput: 5, zInput: -4});

  print(mulValue);

  print(session.getEvaluation(xInput));
  print(session.getEvaluation(yInput));
  print(session.getEvaluation(zInput));
  print(session.getEvaluation(add));
  print(session.getEvaluation(mul));
}
