// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import "node.dart";
import "model_graph.dart";

import "impl/model_session.dart";

abstract class ModelSession {
  factory ModelSession(ModelGraph graph) => new ModelSessionImpl(graph);

  run(Node target, Map<PlaceHolderNode, dynamic> inputs);

  getEvaluation(Node target);
}
