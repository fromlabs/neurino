// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:neurino/neurino.dart';

main() {
  // model graph

  var model = new ModelDescriptor();

  var xInput = model.registerNode(new Input());
  var yInput = model.registerNode(new Input());
  var zVariable = model.registerNode(new Variable());

  var constant = model.registerNode(new Constant(-4));

  var init = model.registerNode(new VariableUpdate(zVariable, constant));

  var add = model.registerNode(new Add(xInput, yInput));
  var mul = model.registerNode(new Mul(add, zVariable));

  // model session
  var session = new Session(model);

  // init
  session.run(init);

  print(session.getEvaluation(zVariable));

  // evaluation
  print(session.run(mul, inputs: {xInput: -2, yInput: 5}));
}
