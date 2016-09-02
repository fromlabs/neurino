// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import "dart:async";

import "../model.dart";

import "model.dart";
import "node.dart";
import "variable.dart";

final ModelImpl defaultModel = new Model();
const String _defaultContainerKey = "_DEFAULT_CONTAINER";

BaseContainerImpl get defaultContainer =>
    Zone.current[_defaultContainerKey] ?? defaultModel;

abstract class BaseContainerImpl {
  final Map<String, int> _autoNodeIds = {};
  final Map<String, BaseNodeImpl> _nodes = {};

  BaseContainerImpl get parent;

  Iterable<VariableImpl> get allVariables =>
      allNodes.where((node) => node is VariableImpl);

  Iterable<BaseNodeImpl> get allNodes => _nodes.values
      .expand((node) => node is CompositeImpl ? node.allNodes : [node]);

  void asDefault(void scopedRunnable()) {
    runZoned(scopedRunnable, zoneValues: {_defaultContainerKey: this});
  }

  void registerNode(BaseNodeImpl node) {
    if (_nodes.containsKey(node.id)) {
      throw new ArgumentError.value(
          node.id, "id", "Node already registered with the same identifier");
    }

    _nodes[node.id] = node;
  }

  String createNewId(String nodeType) {
    nodeType ??= "node";
    var newId = _autoNodeIds.putIfAbsent(nodeType, () => -1) + 1;
    _autoNodeIds[nodeType] = newId;
    return "$nodeType/$newId";
  }
}
