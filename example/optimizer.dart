// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:neurino/neurino.dart';

main() {
  /* MODEL GRAPH */

  var model = new ModelDescriptor();

  var x = model.register(new PlaceHolder());
  var w = model.register(new Variable());
  var b = model.register(new Variable());

  var w0 = model.register(new Constant(0));
  var b0 = model.register(new Constant(0));
  var wInit = model.register(new VariableUpdateNode(w, w0));
  var bInit = model.register(new VariableUpdateNode(b, b0));
  var init = model.register(new Batch([wInit, bInit]));

  var mul = model.register(new Mul(x, w));
  var yPredicted = model.register(new Add(mul, b));
  var yReal = model.register(new PlaceHolder());

  var loss = model.register(new Loss1(yPredicted, yReal));

  var optimizer = model.register(new Optimizer(loss));

  /* MODEL SESSION */

  var session = new ModelSession(model);

  // init
  session.run(init, {});

  // step
  print(session.run(optimizer, {x: 1, yReal: 1}));
}
