// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:neurino/neurino.dart';

main() {
  // model graph

  var xInput;
  var yInput;
  var zInput;
  var add;
  var mul;
  var model = new ModelDescriptor();
  model.asDefault(() {
    xInput = new PlaceHolder();
    yInput = new PlaceHolder();
    zInput = new PlaceHolder();

    add = new Add(xInput, yInput);
    mul = new Mul(add, zInput);
  });

  // model session
  var session = new ModelSession(model);
  session.asDefault(() {
    // evaluation
    print(session.run(mul, {xInput: -2, yInput: 5, zInput: -4}));

    print(session.getEvaluation(xInput));
    print(session.getEvaluation(yInput));
    print(session.getEvaluation(zInput));
    print(session.getEvaluation(add));
    print(session.getEvaluation(mul));
  });
}
