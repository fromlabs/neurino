// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import "impl/model.dart";

abstract class Model {
  factory Model() => new ModelImpl();

  void asDefault(void scopedRunnable());
}
