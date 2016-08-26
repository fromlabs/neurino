// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:neurino/neurino.dart';

main() {
  testDefault();

  testScoped();
}

testDefault() {
  var x = new PlaceHolder();
  var yReal = new PlaceHolder();
  var w = new Variable();
  var b = new Variable();

  var mul = new Mul(x, w);
  var yPredicted = new Add(mul, b);
  var loss = new Loss1(yPredicted, yReal);
}

testScoped() {
  var model = new ModelDescriptor();
  model.asDefault(() {
    var x = new PlaceHolder();
    var yReal = new PlaceHolder();
    var w = new Variable();
    var b = new Variable();

    var mul = new Mul(x, w);
    var yPredicted = new Add(mul, b);
    var loss = new Loss1(yPredicted, yReal);
  });
}
