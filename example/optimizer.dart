// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:neurino/neurino.dart';

main() {
  /* MODEL GRAPH */

  var model = new ModelGraph();

  var x = model.register(new PlaceHolderNode());
  var w = model.register(new VariableNode());
  var b = model.register(new VariableNode());

  var w0 = model.register(new ConstantNode(0));
  var b0 = model.register(new ConstantNode(0));
  var wInit = model.register(new VariableUpdateNode(w, w0));
  var bInit = model.register(new VariableUpdateNode(b, b0));
  var init = model.register(new BatchNode([wInit, bInit]));

  var mul = model.register(new MulNode(x, w));
  var yPredicted = model.register(new AddNode(mul, b));
  var yReal = model.register(new PlaceHolderNode());

  var loss = model.register(new Loss1Node(yPredicted, yReal));

  var optimizer = model.register(new OptimizerNode(loss));

  /* MODEL SESSION */

  var session = new ModelSession(model);

  // init
  session.run(init, {});

  // step
  print(session.run(optimizer, {x: 1, yReal: 1}));
}
