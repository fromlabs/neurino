// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:neurino/neurino.dart';

main() {
  // model graph

  var x = new ModelInput();

  var y0 = new Constant(0);

  var y = x;
  var y1 = new Memory(y, y0);
  var y2 = new Memory(y1, y0);

  var ys = new Batch([y, y1, y2]);

  // model session

  var session = new Session();

  print(session.run(ys, inputs: {x: 1}));
  print(session.run(ys, inputs: {x: 2}));
  print(session.run(ys, inputs: {x: 3}));
  print(session.run(ys, inputs: {x: 4}));
}
