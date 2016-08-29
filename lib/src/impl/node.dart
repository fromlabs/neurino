// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

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

abstract class LocalNodeImpl extends NodeImpl {
  LocalNodeImpl(String id, String type) : super(id, type);

  calculateEvaluation(Map<NodeImpl, dynamic> dependencyValues, NodeState state);

  calculateDerivativeEvaluation(
      Map<NodeImpl, dynamic> dependencyValues, NodeState state) {
    throw new UnsupportedError("Derivative evaluation on $this");
  }

  void evaluate(Map<NodeImpl, dynamic> dependencyValues, NodeState state) {
    updateEvaluation(calculateEvaluation(dependencyValues, state), state);
  }
}

abstract class SessionNodeImpl extends NodeImpl {
  SessionNodeImpl(String id, String type) : super(id, type);

  calculateEvaluation(SessionImpl session);

  void evaluate(SessionImpl session) {
    updateEvaluation(calculateEvaluation(session), session.getNodeState(this));
  }
}

abstract class CompositeNodeImpl extends LocalNodeImpl {
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

class ConstantImpl extends LocalNodeImpl implements Constant {
  static const String _type = "constant";

  final _value;

  ConstantImpl(this._value, {String id}) : super(id, _type);

  @override
  bool isEvaluated(NodeState state) => true;

  @override
  getEvaluation(NodeState state) => _value;

  @override
  calculateEvaluation(
      Map<NodeImpl, dynamic> dependencyValues, NodeState state) {
    throw new UnsupportedError("Can't be here");
  }
}

class InputImpl extends LocalNodeImpl implements Input {
  static const String _type = "input";

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
class VariableImpl extends LocalNodeImpl implements Variable {
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
    throw new StateError("Variable $this not initialized");
  }
}

class VariableUpdateImpl extends SessionNodeImpl implements VariableUpdate {
  static const String _type = "variable_update";

  final VariableImpl _variable;
  final NodeImpl _input;

  VariableUpdateImpl(VariableImpl variable, input, {String id})
      : this._variable = variable,
        this._input = toNode(input),
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
