// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:neurino/neurino.dart';

main() {
  /* MODEL GRAPH */

  var model = new ModelGraph();

  var x = model.register(new PlaceHolderNode());
  var y = model.register(new PlaceHolderNode());
  var z = model.register(new PlaceHolderNode());
  var w = model.register(new PlaceHolderNode());

  var mul1 = model.register(new MulNode(x, y));
  var max1 = model.register(new MaxNode(z, w));
  var add2 = model.register(new AddNode(mul1, max1));
  var k2 = model.register(new ConstantNode(2));
  var mul3 = model.register(new MulNode(add2, k2));

  var k0 = model.register(new ConstantNode(0));
  var k1 = model.register(new ConstantNode(1));

  var d_mul3__d_mul3 = k1;

  var d_mul3__d_add2 = model.register(new MulNode(d_mul3__d_mul3, k2));
  // var d_mul3__dk2 = 0; // costante!

  var d_add2__d_mul1 = k1;
  var d_add2__d_max1 = k1;

  var d_mul3__d_mul1 =
      model.register(new MulNode(d_mul3__d_add2, d_add2__d_mul1));
  var d_mul3__d_max1 =
      model.register(new MulNode(d_mul3__d_add2, d_add2__d_max1));

  var d_mul1__d_x = y;
  var d_mul1__d_y = x;

  var d_mul3__d_x = model.register(new MulNode(d_mul3__d_mul1, d_mul1__d_x));
  var d_mul3__d_y = model.register(new MulNode(d_mul3__d_mul1, d_mul1__d_y));

  var zGreaterEqualW = model.register(new GreaterEqualNode(z, w));
  var notZGreaterEqualW = model.register(new NotNode(zGreaterEqualW));

  var d_max1__d_z = model.register(new IfNode(zGreaterEqualW, k1, k0));
  var d_max1__d_w = model.register(new IfNode(notZGreaterEqualW, k1, k0));

  var d_mul3__d_z = model.register(new MulNode(d_mul3__d_max1, d_max1__d_z));
  var d_mul3__d_w = model.register(new MulNode(d_mul3__d_max1, d_max1__d_w));

  var gradients = model.register(
      new BatchNode([d_mul3__d_x, d_mul3__d_y, d_mul3__d_z, d_mul3__d_w]));

  /* MODEL SESSION */

  var session = new ModelSession(model);

  // step
  session.run(gradients, {x: 3, y: -4, z: 2, w: -1});
  print(session.getEvaluation(gradients));

  session.run(gradients, {x: 3, y: -4, z: -2, w: 1});
  print(session.getEvaluation(gradients));
}