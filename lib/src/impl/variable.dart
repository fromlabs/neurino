// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import "../variable.dart";

import "container.dart";
import "node.dart";
import "session.dart";

class VariableImpl extends BaseNodeImpl implements Variable {
  static const String _type = "variable";

  static const String _UPDATED_KEY = "_UPDATED";

  final VariableInitializer _initialize;

  VariableImpl(this._initialize, {String id}) : super(id, _type);

  @override
  void initializeState(NodeState newState, NodeState previousState) {
    if (previousState.isEvaluated) {
      newState.evaluation = previousState.evaluation;
    }
  }

  void initializeVariable() {
    updateEvaluation(_initialize());
  }

  @override
  get evaluation {
    if (!isEvaluated) {
      throw new StateError("Variable $this not initialized");
    }

    return super.evaluation;
  }

  @override
  void updateEvaluation(value) {
    if (state == null) {
      throw new StateError("Session not runned yet");
    } else if (state.contains(_UPDATED_KEY)) {
      throw new StateError("Variable $this already updated");
    }

    state.evaluation = value;

    state[_UPDATED_KEY] = true;
  }

  @override
  calculateEvaluation() {
    throw new StateError("Variable $this not initialized");
  }
}

class VariableUpdateImpl extends BaseNodeImpl implements VariableUpdate {
  static const String _type = "variable_update";

  final VariableImpl _variable;
  final BaseNodeImpl _value;

  VariableUpdateImpl(this._variable, this._value, {String id})
      : super(id, _type) {
    checkInternalDependency(_variable);
    checkInternalDependency(_value);
  }

  @override
  calculateEvaluation() {
    var value = _value.evaluate();

    _variable.updateEvaluation(value);

    return true;
  }
}

class AllVariableInitializeImpl extends BaseNodeImpl
    implements AllVariableInitialize {
  static const String _type = "all_variable_initialize";

  AllVariableInitializeImpl({String id}) : super(id, _type);

  @override
  calculateEvaluation() {
    defaultContainer.allVariables.forEach((VariableImpl variable) {
      variable.initializeVariable();
    });

    return true;
  }
}
