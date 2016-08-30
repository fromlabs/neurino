// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:neurino/neurino.dart';

main() {
  var x1 = new ModelInput(id: "x");

  try {
    print(new Constant(0, id: "x"));

    throw new AssertionError();
  } on ArgumentError {
    // pass
  }

  var yReal1 = new ModelInput();
  var w1 = new Variable();
  var b1 = new Variable();

  var mul1 = new Mul(x1, w1);
  var yPredicted1 = new Add(mul1, b1);
  var loss1 = new Loss1(yPredicted1, yReal1);

  print(x1);
  print(loss1);

  var model2 = new ModelDescriptor();
  model2.asDefault(() {
    try {
      new Negate(x1);

      throw new AssertionError();
    } on ArgumentError {
      // pass
    }

    var x2 = new ModelInput(id: "x");
    var yReal2 = new ModelInput();
    var w2 = new Variable();
    var b2 = new Variable();

    var mul2 = new Mul(x2, w2);
    var yPredicted2 = new Add(mul2, b2);
    var loss2 = new Loss1(yPredicted2, yReal2);

    print(x2);
    print(loss2);
  });
}
