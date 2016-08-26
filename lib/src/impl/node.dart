// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import "../model_descriptor.dart";
import "../node.dart";

import "model_descriptor.dart";
import "session.dart";
import "model_state.dart";

abstract class NodeImpl implements Node {
  final String id;

  final ModelDescriptorImpl _descriptor;

  NodeImpl(String id, String type)
      : this.id = id ?? autoId(type),
        this._descriptor = defaultDescriptor {
    _descriptor.registerNode(this);
  }

  void registerNodeDependency(NodeImpl dependency) {
    _descriptor.registerNodeDependency(this, dependency);
  }

  void initializeState(NodeState newState, NodeState previousState) {}

  bool isEvaluated(NodeState state) => state.isEvaluated;

  getEvaluation(NodeState state) {
    if (!isEvaluated(state)) {
      throw new StateError("Node $this not evaluated");
    }

    return state.evaluation;
  }

  void updateEvaluation(value, NodeState state) {
    if (isEvaluated(state)) {
      throw new StateError("Node $this already evaluated");
    }

    state.evaluation = value;
  }

  @override
  String toString() => "\"$id\"";
}

abstract class EvaluationNodeImpl extends NodeImpl {
  EvaluationNodeImpl(String id, String type) : super(id, type);

  calculateEvaluation(Map<NodeImpl, dynamic> dependencyValues, NodeState state);

  void evaluate(Map<NodeImpl, dynamic> dependencyValues, NodeState state) {
    updateEvaluation(calculateEvaluation(dependencyValues, state), state);
  }
}

abstract class ActionNodeImpl extends NodeImpl {
  ActionNodeImpl(String id, String type) : super(id, type);

  calculateEvaluation(SessionImpl session);

  void evaluate(SessionImpl session) {
    updateEvaluation(calculateEvaluation(session), session.getNodeState(this));
  }
}

abstract class CompositeNodeImpl extends EvaluationNodeImpl {
  final NodeImpl _main;

  CompositeNodeImpl.internal(this._main, String id, String type)
      : super(id, type) {
    registerNodeDependency(_main);
  }

  @override
  calculateEvaluation(
          Map<NodeImpl, dynamic> dependencyValues, NodeState state) =>
      dependencyValues[_main];
}

class InputImpl extends EvaluationNodeImpl implements Input {
  static const String _type = "input";

  static const String _HOLD_KEY = "_HOLD";

  InputImpl({String id}) : super(id, _type);

  @override
  getEvaluation(NodeState state) {
    if (!isEvaluated(state)) {
      throw new StateError("Input $this not specified");
    }

    return super.getEvaluation(state);
  }

  @override
  calculateEvaluation(
      Map<NodeImpl, dynamic> dependencyValues, NodeState state) {
    throw new StateError("Input $this not specified");
  }
}

// la variabile deve essere inizializzata
// la variabile una volta inizializzata è sempre evaluated
// la variabile può essere assegnata (inizializzata o aggiornata) solo una volta per esecuzione
class VariableImpl extends EvaluationNodeImpl implements Variable {
  static const String _type = "variable";

  static const String _VAR_KEY = "_VAR";

  VariableImpl({String id}) : super(id, _type);

  void initialize(NodeState state) {
    // TODO to implement inizializzazione variabili
    throw new UnimplementedError("TO IMPLEMENT");
  }

  @override
  void initializeState(NodeState newState, NodeState previousState) {
    if (isEvaluated(previousState)) {
      newState.evaluation = previousState.evaluation;
    }
  }

  @override
  getEvaluation(NodeState state) {
    if (!isEvaluated(state)) {
      throw new StateError("Variable $this not initialized");
    }

    return super.getEvaluation(state);
  }

  @override
  void updateEvaluation(value, NodeState state) {
    if (state.contains(_VAR_KEY)) {
      throw new StateError("Variable $this already updated");
    }

    state.evaluation = value;

    state.set(_VAR_KEY, _VAR_KEY);
  }

  @override
  calculateEvaluation(
      Map<NodeImpl, dynamic> dependencyValues, NodeState state) {
    throw new StateError("Can't be here");
  }
}

class VariableUpdateImpl extends ActionNodeImpl implements VariableUpdate {
  static const String _type = "variable_update";

  final VariableImpl _variable;
  final NodeImpl _input;

  VariableUpdateImpl(VariableImpl variable, NodeImpl input, {String id})
      : this._variable = variable,
        this._input = input,
        super(id, _type) {
    registerNodeDependency(_variable);
    registerNodeDependency(_input);
  }

  @override
  calculateEvaluation(SessionImpl session) {
    _variable.updateEvaluation(
        session.evaluateNode(_input), session.getNodeState(_variable));
  }
}
