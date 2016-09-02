// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import "node.dart";
import "model.dart";

import "impl/session.dart";

abstract class Session {
  factory Session([Model model]) => new SessionImpl(model);

  void asDefault(void scopedRunnable());

  run(Node target, {Map<ModelInput, dynamic> inputs: const {}});
}
