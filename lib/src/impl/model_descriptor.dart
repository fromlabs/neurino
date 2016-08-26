// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import "dart:async";

import "../model_descriptor.dart";

import "node.dart";

const String _DEFAULT_DESCRIPTOR_KEY = "_DEFAULT_DESCRIPTOR";
final ModelDescriptorImpl _DEFAULT_DESCRIPTOR = new ModelDescriptorImpl();

ModelDescriptorImpl get defaultDescriptor =>
    Zone.current[_DEFAULT_DESCRIPTOR_KEY] ?? _DEFAULT_DESCRIPTOR;

String autoId(String nodeType) => defaultDescriptor.autoId(nodeType);

class ModelDescriptorImpl implements ModelDescriptor {
  final Map<String, int> _autoNodeIds = {};
  final Map<String, NodeImpl> _nodes = {};
  final Map<String, List<String>> _dependencies = {};

  List<NodeImpl> get nodes => _nodes.values.toList(growable: false);

  NodeImpl getNode(String id) {
    if (!_nodes.containsKey(id)) {
      throw new ArgumentError.value(id, "id", "Node not registered");
    }

    return _nodes[id];
  }

  List<NodeImpl> getNodeDependencies(NodeImpl node) {
    List<String> ids = _dependencies[node.id] ?? [];
    return ids.map((id) => _nodes[id]).toList(growable: false);
  }

  @override
  void asDefault(void scopedRunnable()) {
    runZoned(scopedRunnable, zoneValues: {_DEFAULT_DESCRIPTOR_KEY: this});
  }

  String autoId(String nodeType) {
    nodeType ??= "node";
    var newId = _autoNodeIds.putIfAbsent(nodeType, () => -1) + 1;
    _autoNodeIds[nodeType] = newId;
    return "$nodeType/$newId";
  }

  void registerNode(NodeImpl node) {
    if (_nodes.containsKey(node.id)) {
      throw new ArgumentError.value(
          node.id, "id", "Node already registered with the same identifier");
    }

    _nodes[node.id] = node;
  }

  void registerNodeDependency(NodeImpl node, NodeImpl dependency) {
    if (!_nodes.containsKey(dependency.id)) {
      throw new ArgumentError(
          "Dependency node $dependency not registered to the same model descriptor of node $node");
    }

    _dependencies.putIfAbsent(node.id, () => []).add(dependency.id);
  }
}
