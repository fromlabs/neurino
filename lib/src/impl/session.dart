// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import "../model_descriptor.dart";
import "../session.dart";
import '../node.dart';

import "model_descriptor.dart";
import "model_state.dart";
import 'node.dart';

class SessionImpl implements Session {
  final ModelDescriptorImpl _descriptor;

  ModelState _state;

  SessionImpl(ModelDescriptorImpl descriptor)
      : this._descriptor = descriptor ?? defaultDescriptor;

  @override
  getEvaluation(Node node) {
    _checkState();

    NodeImpl nodeImpl = node;

    return nodeImpl.getEvaluation(getNodeState(node));
  }

  @override
  run(Node target, {Map<Input, dynamic> inputs: const {}}) {
    var previousState = _state;

    try {
      _state = _prepareNewState(previousState);

      _initializePlaceholders(inputs);

      return evaluateNode(target);
    } catch (e) {
      _state = previousState;

      rethrow;
    }
  }

  NodeState getNodeState(NodeImpl node) => _state.get(node);

  evaluateNode(NodeImpl target) {
    var targetState = getNodeState(target);
    if (!target.isEvaluated(targetState)) {
      if (target is ActionNodeImpl) {
        target.evaluate(this);
      } else if (target is EvaluationNodeImpl) {
        var dependencyValues = new Map.fromIterable(
            _descriptor.getNodeDependencies(target),
            value: (dependencyTarget) => evaluateNode(dependencyTarget));

        target.evaluate(dependencyValues, targetState);
      }
    }

    return target.getEvaluation(targetState);
  }

  void _checkState() {
    if (_state == null) {
      throw new StateError("Session not runned yet");
    }
  }

  ModelState _prepareNewState(ModelState previousState) {
    var newState = new ModelState();

    if (previousState != null) {
      _descriptor.nodes
          .where((node) => previousState.contains(node))
          .forEach((node) {
        node.initializeState(newState.get(node), previousState.get(node));
      });
    }

    return newState;
  }

  void _initializePlaceholders(Map<Input, dynamic> inputs) {
    inputs.forEach((node, value) {
      InputImpl holderImpl = node;

      holderImpl.updateEvaluation(value, getNodeState(node));
    });
  }
}
