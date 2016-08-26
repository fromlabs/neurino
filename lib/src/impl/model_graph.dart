// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import "../model_graph.dart";
import '../node.dart';

import 'node.dart';

class ModelGraphImpl implements ModelGraph {
  @override
  Node register(Node node) {
    NodeImpl impl = node;
    impl.registerModelGraph(this);
    return node;
  }
}
