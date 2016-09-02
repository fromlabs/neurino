// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import "dart:async";

import "../node.dart";
import "../session.dart";

import "container.dart";
import "model.dart";
import 'node.dart';

const String _defaultSessionKey = "_DEFAULT_SESSION";

SessionImpl get defaultSession => Zone.current[_defaultSessionKey];

class SessionImpl implements Session {
  final ModelImpl _model;

  ModelState _state;

  SessionImpl([ModelImpl model]) : this._model = model ?? defaultModel;

  void asDefault(void scopedRunnable()) {
    if (defaultContainer != _model) {
      _model.asDefault(() {
        runZoned(scopedRunnable, zoneValues: {_defaultSessionKey: this});
      });
    } else {
      runZoned(scopedRunnable, zoneValues: {_defaultSessionKey: this});
    }
  }

  @override
  run(Node target, {Map<ModelInput, dynamic> inputs: const {}}) {
    var previousState = _state;

    try {
      _state = new ModelState(previousState);

      _initializeModelInputs(inputs);

      BaseNodeImpl impl = target;

      return impl.evaluate();
    } catch (e) {
      _state = previousState;

      rethrow;
    }
  }

  NodeState getNodeState(BaseNodeImpl node) =>
      _state != null ? _state[node] : null;

  void _initializeModelInputs(Map<ModelInput, dynamic> inputs) {
    inputs.forEach((node, value) {
      ModelInputImpl inputImpl = node;

      inputImpl.updateEvaluation(value);
    });
  }
}

class ModelState {
  final Map<BaseNodeImpl, NodeState> _states = {};

  ModelState(ModelState previousState) {
    if (previousState != null) {
      previousState._states.forEach((node, previousState) {
        node.initializeState(this[node], previousState);
      });
    }
  }

  bool contains(BaseNodeImpl node) => _states.containsKey(node);

  NodeState operator [](BaseNodeImpl node) =>
      _states.putIfAbsent(node, () => new NodeState());
}

class NodeState {
  static const String _EVALUATION_KEY = "_EVALUATION";

  static const String _LOCAL_GRADIENT_KEY = "_LOCAL_GRADIENT";

  static const String _TARGET_GRADIENT_KEY = "_TARGET_GRADIENT";

  final Map<dynamic, dynamic> _values = {};

  bool get isEvaluated => contains(_EVALUATION_KEY);

  get evaluation => this[_EVALUATION_KEY];

  void set evaluation(value) {
    this[_EVALUATION_KEY] = value;
  }

  bool get isLocalGradientEvaluated => contains(_LOCAL_GRADIENT_KEY);

  get localGradient => this[_LOCAL_GRADIENT_KEY];

  void set localGradient(value) {
    this[_LOCAL_GRADIENT_KEY] = value;
  }

  bool get isTargetGradientEvaluated => contains(_TARGET_GRADIENT_KEY);

  get targetGradient => this[_TARGET_GRADIENT_KEY];

  void set targetGradient(value) {
    this[_TARGET_GRADIENT_KEY] = value;
  }

  bool contains(key) => _values.containsKey(key);

  operator [](key) => _values[key];

  void operator []=(key, value) {
    _values[key] = value;
  }
}
