// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import "node.dart";
import "model_descriptor.dart";

import "impl/session.dart";

abstract class Session {
  factory Session([ModelDescriptor descriptor]) =>
      new SessionImpl(descriptor);

  run(Node target, {Map<Input, dynamic> inputs: const {}});

  getEvaluation(Node node);
}
