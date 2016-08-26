// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:neurino/neurino.dart';

main() {
  /* MODEL GRAPH */

  var model = new ModelDescriptor();

  var x = model.registerNode(new Input());
  var w = model.registerNode(new Variable());
  var b = model.registerNode(new Variable());

  var w0 = model.registerNode(new Constant(0));
  var b0 = model.registerNode(new Constant(0));
  var wInit = model.registerNode(new VariableUpdate(w, w0));
  var bInit = model.registerNode(new VariableUpdate(b, b0));
  var init = model.registerNode(new Batch([wInit, bInit]));

  var mul = model.registerNode(new Mul(x, w));
  var yPredicted = model.registerNode(new Add(mul, b));
  var yReal = model.registerNode(new Input());

  var loss = model.registerNode(new Loss1(yPredicted, yReal));

  /* MODEL SESSION */

  var session = new Session(model);

  // init
  session.run(init);

  // step
  print(session.run(loss, inputs: {x: 1, yReal: 1}));
}
