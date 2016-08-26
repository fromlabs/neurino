// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:neurino/neurino.dart';

main() {
  // model graph

  var model = new ModelGraph();

  var xInput = model.register(new PlaceHolderNode());
  var yInput = model.register(new PlaceHolderNode());
  var zInput = model.register(new PlaceHolderNode());

  var add = model.register(new AddNode(xInput, yInput));
  var mul = model.register(new MulNode(add, zInput));

  // model session

  var session = new ModelSession(model);

  // evaluation
  var mulValue = session.run(mul, {xInput: -2, yInput: 5, zInput: -4});

  print(mulValue);

  print(session.getEvaluation(xInput));
  print(session.getEvaluation(yInput));
  print(session.getEvaluation(zInput));
  print(session.getEvaluation(add));
  print(session.getEvaluation(mul));

  // TODO implementare le variabili
}
