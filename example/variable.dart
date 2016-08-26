// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:neurino/neurino.dart';

main() {
  // model graph

  var model = new ModelGraph();

  var xInput = model.register(new PlaceHolderNode());
  var yInput = model.register(new PlaceHolderNode());
  var zVariable = model.register(new VariableNode());

  var constant = model.register(new ConstantNode(-4));

  var init = model.register(new VariableUpdateNode(zVariable, constant));

  var add = model.register(new AddNode(xInput, yInput));
  var mul = model.register(new MulNode(add, zVariable));

  // model session
  var session = new ModelSession(model);

  // init
  session.run(init, {});

  print(session.getEvaluation(zVariable));

  // evaluation
  print(session.run(mul, {xInput: -2, yInput: 5}));
}
