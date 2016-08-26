// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:neurino/neurino.dart';

main() {
  /* MODEL GRAPH */

  var model = new ModelGraph();

  var xInput = model.register(new VariableNode());
  var yInput = model.register(new ConstantNode(2));

  var xInitial = model.register(new ConstantNode(1));
  var init = model.register(new VariableUpdateNode(xInput, xInitial));

  var mul = model.register(new MulNode(xInput, yInput));
  var update = model.register(new VariableUpdateNode(xInput, mul));

  /* MODEL SESSION */

  var session = new ModelSession(model);

  // init
  session.run(init, {});
  print(session.getEvaluation(xInput));

  // update step
  session.run(update, {});
  print(session.getEvaluation(mul));

  // update step
  session.run(update, {});
  print(session.getEvaluation(mul));

  // update step
  session.run(update, {});
  print(session.getEvaluation(mul));
}
