// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import "../model_descriptor.dart";
import "../session.dart";
import '../node.dart';

import 'node.dart';

class ModelSessionImpl implements ModelSession {
  final ModelDescriptor _graph;

  ModelState _state;

  ModelSessionImpl(this._graph);

  @override
  getEvaluation(Node target) => _state.get(target).evaluation;

  @override
  run(Node target, Map<PlaceHolder, dynamic> inputs) {
    _state = new ModelState(_state);

    _initializePlaceHolders(inputs);

    return _evaluateNode(target);
  }

  NodeState _getNodeState(Node node) => _state.get(node);

  void _initializePlaceHolders(Map<PlaceHolder, dynamic> inputs) {
    inputs.forEach((node, value) {
      PlaceHolderImpl holderImpl = node;

      holderImpl.hold(value, _getNodeState(node));
    });
  }

  _evaluateNode(NodeImpl target) {
    var targetState = _getNodeState(target);
    if (!targetState.isEvaluated) {
      var dependencyValues;
      if (target is VariableUpdateImpl) {
        var value = _updateVariable(target.variable, target.input);

        dependencyValues = {target.variable: value, target.input: value};
      } else {
        dependencyValues = new Map.fromIterable(target.dependencies,
            value: (dependencyTarget) => _evaluateNode(dependencyTarget));
      }

      target.evaluate(dependencyValues, targetState);
    }

    return targetState.evaluation;
  }

  _updateVariable(VariableImpl target, NodeImpl source) {
    var targetState = _getNodeState(target);

    var value = _evaluateNode(source);

    target.update(value, targetState);

    targetState.evaluation;
  }
}

class ModelState {
  final Map<Node, NodeState> _states = {};

  ModelState(ModelState previous) {
    if (previous != null) {
      previous._states.forEach((node, previousState) {
        _states[node] = new NodeState(previousState);
      });
    }
  }

  NodeState get(Node node) {
    var state = _states[node];
    if (state == null) {
      state = new NodeState(null);

      _states[node] = state;
    }
    return state;
  }
}

class NodeState {
  static const String _EVALUATION_KEY = "_EVALUATION";

  final Map<dynamic, dynamic> _sessionValues;

  final Map<dynamic, dynamic> _executionValues;

  NodeState(NodeState previous)
      : _executionValues = {},
        _sessionValues = previous != null ? previous._sessionValues : {};

  bool get isEvaluated => containsExecutionValue(_EVALUATION_KEY);

  dynamic get evaluation {
    if (!isEvaluated) {
      throw new StateError("Node not evaluated");
    }

    return getExecutionValue(_EVALUATION_KEY);
  }

  void set evaluation(evaluation) {
    return setExecutionValue(_EVALUATION_KEY, evaluation);
  }

  bool containsSessionValue(key) => _sessionValues.containsKey(key);

  getSessionValue(key) {
    if (!containsSessionValue(key)) {
      throw new StateError("Node session value not exist $key");
    }

    return _sessionValues[key];
  }

  void setSessionValue(key, value) {
    _sessionValues[key] = value;
  }

  containsExecutionValue(key) => _executionValues.containsKey(key);

  getExecutionValue(key) {
    if (!containsExecutionValue(key)) {
      throw new StateError("Node execution value not exist $key");
    }

    return _executionValues[key];
  }

  void setExecutionValue(key, value) {
    _executionValues[key] = value;
  }
}
