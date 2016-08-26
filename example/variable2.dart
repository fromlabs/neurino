// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:neurino/neurino.dart';

main() {
  /* MODEL GRAPH */

  var model = new ModelDescriptor();

  var xInput = model.registerNode(new Variable());
  var yInput = model.registerNode(new Constant(2));

  var xInitial = model.registerNode(new Constant(1));
  var init = model.registerNode(new VariableUpdate(xInput, xInitial));

  var mul = model.registerNode(new Mul(xInput, yInput));
  var update = model.registerNode(new VariableUpdate(xInput, mul));

  /* MODEL SESSION */

  var session = new Session(model);

  // init
  session.run(init);
  print(session.getEvaluation(xInput));

  // update step
  session.run(update);
  print(session.getEvaluation(mul));

  // update step
  session.run(update);
  print(session.getEvaluation(mul));

  // update step
  session.run(update);
  print(session.getEvaluation(mul));
}
