// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import "node.dart";

import "impl/model_graph.dart";

abstract class ModelGraph {
  factory ModelGraph() => new ModelGraphImpl();

  Node register(Node node);
}