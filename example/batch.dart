// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:neurino/neurino.dart';

main() {
  /* MODEL GRAPH */

  var model = new ModelDescriptor();

  var xInput = model.register(new Variable());
  var yInput = model.register(new Constant(2));

  var xInitial = model.register(new Constant(1));
  var init = model.register(new VariableUpdateNode(xInput, xInitial));

  var mul = model.register(new Mul(xInput, yInput));
  var update = model.register(new VariableUpdateNode(xInput, mul));

  var batch = model.register(new Batch([xInput, yInput, update]));

  /* MODEL SESSION */

  var session = new ModelSession(model);

  // init
  print(session.run(init, {}));

  // update step
  print(session.run(batch, {}));

  // update step
  print(session.run(batch, {}));

  // update step
  print(session.run(batch, {}));
}
