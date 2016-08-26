// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:neurino/neurino.dart';

main() {
  /* MODEL GRAPH */

  var model = new ModelDescriptor();

  var x = model.registerNode(new Input());
  var y = model.registerNode(new Input());
  var z = model.registerNode(new Input());
  var w = model.registerNode(new Input());

  var mul1 = model.registerNode(new Mul(x, y));
  var max1 = model.registerNode(new Max(z, w));
  var add2 = model.registerNode(new Add(mul1, max1));
  var k2 = model.registerNode(new Constant(2));
  var mul3 = model.registerNode(new Mul(add2, k2));

  var k0 = model.registerNode(new Constant(0));
  var k1 = model.registerNode(new Constant(1));

  var d_mul3__d_mul3 = k1;

  var d_mul3__d_add2 = model.registerNode(new Mul(d_mul3__d_mul3, k2));
  // var d_mul3__dk2 = 0; // costante!

  var d_add2__d_mul1 = k1;
  var d_add2__d_max1 = k1;

  var d_mul3__d_mul1 =
      model.registerNode(new Mul(d_mul3__d_add2, d_add2__d_mul1));
  var d_mul3__d_max1 =
      model.registerNode(new Mul(d_mul3__d_add2, d_add2__d_max1));

  var d_mul1__d_x = y;
  var d_mul1__d_y = x;

  var d_mul3__d_x = model.registerNode(new Mul(d_mul3__d_mul1, d_mul1__d_x));
  var d_mul3__d_y = model.registerNode(new Mul(d_mul3__d_mul1, d_mul1__d_y));

  var zGreaterEqualW = model.registerNode(new GreaterEqual(z, w));
  var notZGreaterEqualW = model.registerNode(new Not(zGreaterEqualW));

  var d_max1__d_z = model.registerNode(new If(zGreaterEqualW, k1, k0));
  var d_max1__d_w = model.registerNode(new If(notZGreaterEqualW, k1, k0));

  var d_mul3__d_z = model.registerNode(new Mul(d_mul3__d_max1, d_max1__d_z));
  var d_mul3__d_w = model.registerNode(new Mul(d_mul3__d_max1, d_max1__d_w));

  var gradients = model.registerNode(
      new Batch([d_mul3__d_x, d_mul3__d_y, d_mul3__d_z, d_mul3__d_w]));

  /* MODEL SESSION */

  var session = new Session(model);

  // step
  session.run(gradients, inputs: {x: 3, y: -4, z: 2, w: -1});
  print(session.getEvaluation(gradients));

  session.run(gradients, inputs: {x: 3, y: -4, z: -2, w: 1});
  print(session.getEvaluation(gradients));
}
