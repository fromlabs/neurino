// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import "node.dart";

class ModelState {
  final Map<String, NodeState> _states = {};

  bool contains(NodeImpl node) => _states.containsKey(node.id);

  NodeState get(NodeImpl node) =>
      _states.putIfAbsent(node.id, () => new NodeState());
}

class NodeState {
  static const String _EVALUATION_KEY = "_EVALUATION";

  final Map<dynamic, dynamic> _values = {};

  NodeState();

  bool get isEvaluated => contains(_EVALUATION_KEY);

  dynamic get evaluation => get(_EVALUATION_KEY);

  void set evaluation(evaluation) => set(_EVALUATION_KEY, evaluation);

  bool contains(key) => _values.containsKey(key);

  get(key) => _values[key];

  void set(key, value) {
    _values[key] = value;
  }
}
