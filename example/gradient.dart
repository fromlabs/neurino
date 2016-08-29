// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:neurino/neurino.dart';

main() {
  /* MODEL GRAPH */

  var x = new Input();
  var y = new Input();
  var z = new Input();
  var w = new Input();

  var mul1 = new Mul(x, y);
  var max1 = new Max(z, w);
  var add2 = new Add(mul1, max1);
  var k2 = 2;
  var mul3 = new Mul(add2, k2);

  var d_mul3__d_mul3 = 1;

  var d_mul3__d_add2 = new Mul(d_mul3__d_mul3, k2);
  // var d_mul3__dk2 = 0; // costante!

  var d_add2__d_mul1 = 1;
  var d_add2__d_max1 = 1;

  var d_mul3__d_mul1 = new Mul(d_mul3__d_add2, d_add2__d_mul1);
  var d_mul3__d_max1 = new Mul(d_mul3__d_add2, d_add2__d_max1);

  var d_mul1__d_x = y;
  var d_mul1__d_y = x;

  var d_mul3__d_x = new Mul(d_mul3__d_mul1, d_mul1__d_x);
  var d_mul3__d_y = new Mul(d_mul3__d_mul1, d_mul1__d_y);

  var zGreaterEqualW = new GreaterEqual(z, w);
  var notZGreaterEqualW = new Not(zGreaterEqualW);

  var d_max1__d_z = new If(zGreaterEqualW, 1, 0);
  var d_max1__d_w = new If(notZGreaterEqualW, 1, 0);

  var d_mul3__d_z = new Mul(d_mul3__d_max1, d_max1__d_z);
  var d_mul3__d_w = new Mul(d_mul3__d_max1, d_max1__d_w);

  var gradients =
      new Batch([d_mul3__d_x, d_mul3__d_y, d_mul3__d_z, d_mul3__d_w]);

  /* MODEL SESSION */

  var session = new Session();

  // step
  session.run(gradients, inputs: {x: 3, y: -4, z: 2, w: -1});
  print(session[gradients]);

  session.run(gradients, inputs: {x: 3, y: -4, z: -2, w: 1});
  print(session[gradients]);
}
