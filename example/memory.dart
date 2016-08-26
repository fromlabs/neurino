// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:neurino/neurino.dart';

// 1+2
// 2+3
// 3+4
// 4+5
// 5+6
// 7+8

main() {
  // model graph

  var model = new ModelGraph();

  var x = model.register(new PlaceHolderNode());

  var y0 = model.register(new ConstantNode(0));

  var y = x;
  var y1 = model.register(new MemoryNode(y, y0));
  var y2 = model.register(new MemoryNode(y1, y0));

  var ys = model.register(new BatchNode([y, y1, y2]));

  // model session

  var session = new ModelSession(model);

  print(session.run(ys, {x: 1}));
  print(session.run(ys, {x: 2}));
  print(session.run(ys, {x: 3}));
  print(session.run(ys, {x: 4}));
}
