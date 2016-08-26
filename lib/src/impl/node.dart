// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import "dart:math";
import "../model_descriptor.dart";
import "../node.dart";

import "session.dart";

abstract class NodeImpl implements Node {
  final List<Node> _dependencies;

  final List<NodeImpl> _dependants = [];

  ModelDescriptor _graph;

  NodeImpl(this._dependencies);

  List<Node> get dependencies => _dependencies;

  bool get _isRegistered => _graph != null;

  void registerModelGraph(ModelDescriptor graph) {
    if (_isRegistered) {
      throw new StateError("Node already registered");
    }

    _graph = graph;

    for (var dependency in _dependencies) {
      NodeImpl node = dependency;

      // check graph registration
      if (!node._isRegistered) {
        throw new StateError("Dependency node not registered");
      }

      // check same graph
      if (_graph != node._graph) {
        throw new StateError(
            "Dependency node not registered to the same model graph");
      }

      // notify dependant node
      node._registerDependantNode(node);
    }
  }

  void _registerDependantNode(NodeImpl node) {
    _dependants.add(node);
  }

  void evaluate(Map<Node, dynamic> dependencyValues, NodeState state);
}

abstract class CompositeNodeImpl extends NodeImpl {
  final Node _main;

  final List<Node> _internalNodes;

  CompositeNodeImpl.internal(Node main, this._internalNodes)
      : this._main = main,
        super([main]);

  @override
  void evaluate(Map<Node, dynamic> dependencyValues, NodeState state) {
    state.evaluation = dependencyValues[_main];
  }

  void registerModelGraph(ModelDescriptor graph) {
    for (var node in _internalNodes) {
      graph.register(node);
    }

    super.registerModelGraph(graph);
  }
}

class PlaceHolderImpl extends NodeImpl implements PlaceHolder {
  static const String _HOLD_KEY = "_HOLD";

  PlaceHolderImpl() : super([]);

  void hold(value, NodeState state) {
    state.setExecutionValue(_HOLD_KEY, value);
  }

  @override
  void evaluate(Map<Node, dynamic> dependencyValues, NodeState state) {
    state.evaluation = _getHoldedValue(state);
  }

  _getHoldedValue(NodeState state) {
    if (!state.containsExecutionValue(_HOLD_KEY)) {
      throw new StateError("Place holder not initialized");
    }

    return state.getExecutionValue(_HOLD_KEY);
  }
}

class VariableImpl extends NodeImpl implements Variable {
  static const String _VAR_KEY = "_VAR";

  VariableImpl() : super([]);

  @override
  void evaluate(Map<Node, dynamic> dependencyValues, NodeState state) {
    state.evaluation = _getVariableValue(state);
  }

  void update(value, NodeState state) {
    _setVariableValue(value, state);

    state.evaluation = value;
  }

  _getVariableValue(NodeState state) {
    if (!state.containsSessionValue(_VAR_KEY)) {
      throw new StateError("Variable not initialized");
    }

    return state.getSessionValue(_VAR_KEY);
  }

  void _setVariableValue(value, NodeState state) {
    state.setSessionValue(_VAR_KEY, value);
  }
}

class VariableUpdateImpl extends NodeImpl implements VariableUpdateNode {
  final Variable _variable;
  final Node _input;

  VariableUpdateImpl(Variable variable, Node input)
      : this._variable = variable,
        this._input = input,
        super([variable, input]);

  Variable get variable => _variable;

  Node get input => _input;

  @override
  void evaluate(Map<Node, dynamic> dependencyValues, NodeState state) {
    state.evaluation = null;
  }
}

class ConstantNodeImpl extends NodeImpl implements Constant {
  final _value;

  ConstantNodeImpl(this._value) : super([]);

  @override
  void evaluate(Map<Node, dynamic> dependencyValues, NodeState state) {
    state.evaluation = _value;
  }
}

class BatchImpl extends NodeImpl implements Batch {
  final List<Node> _inputs;

  BatchImpl(List<Node> inputs)
      : this._inputs = inputs,
        super(inputs);

  @override
  void evaluate(Map<Node, dynamic> dependencyValues, NodeState state) {
    state.evaluation = dependencyValues;
  }
}

class MemoryImpl extends NodeImpl implements Memory {
  static const String _MEM_KEY = "_MEM";

  final Node _input;
  final Node _initial;

  MemoryImpl(Node input, Node initial)
      : this._input = input,
        this._initial = initial,
        super([input, initial]);

  @override
  void evaluate(Map<Node, dynamic> dependencyValues, NodeState state) {
    state.evaluation = state.containsSessionValue(_MEM_KEY)
        ? state.getSessionValue(_MEM_KEY)
        : dependencyValues[_initial];

    state.setSessionValue(_MEM_KEY, dependencyValues[_input]);
  }
}

class AddImpl extends NodeImpl implements Add {
  final Node _input1;
  final Node _input2;

  AddImpl(Node input1, Node input2)
      : this._input1 = input1,
        this._input2 = input2,
        super([input1, input2]);

  @override
  void evaluate(Map<Node, dynamic> dependencyValues, NodeState state) {
    state.evaluation = dependencyValues[_input1] + dependencyValues[_input2];
  }
}

class MulImpl extends NodeImpl implements Mul {
  final Node _input1;
  final Node _input2;

  MulImpl(Node input1, Node input2)
      : this._input1 = input1,
        this._input2 = input2,
        super([input1, input2]);

  @override
  void evaluate(Map<Node, dynamic> dependencyValues, NodeState state) {
    state.evaluation = dependencyValues[_input1] * dependencyValues[_input2];
  }
}

class NegateImpl extends NodeImpl implements Negate {
  final Node _input;

  NegateImpl(Node input)
      : this._input = input,
        super([input]);

  @override
  void evaluate(Map<Node, dynamic> dependencyValues, NodeState state) {
    state.evaluation = -dependencyValues[_input];
  }
}

class AbsImpl extends NodeImpl implements Abs {
  final Node _input;

  AbsImpl(Node input)
      : this._input = input,
        super([input]);

  @override
  void evaluate(Map<Node, dynamic> dependencyValues, NodeState state) {
    num value = dependencyValues[_input];
    state.evaluation = value.abs();
  }
}

class MaxImpl extends NodeImpl implements Max {
  final Node _input1;
  final Node _input2;

  MaxImpl(Node input1, Node input2)
      : this._input1 = input1,
        this._input2 = input2,
        super([input1, input2]);

  @override
  void evaluate(Map<Node, dynamic> dependencyValues, NodeState state) {
    state.evaluation =
        max(dependencyValues[_input1], dependencyValues[_input2]);
  }
}

class Loss1Impl extends CompositeNodeImpl implements Loss1 {
  factory Loss1Impl(Node input1, Node input2) {
    var negate = new Negate(input2);
    var add = new Add(input1, negate);
    var loss1 = new Abs(add);

    return new Loss1Impl._(loss1, [negate, add, loss1]);
  }

  Loss1Impl._(Node main, List<Node> internalNodes)
      : super.internal(main, internalNodes);
}

class GreaterEqualImpl extends NodeImpl implements GreaterEqual {
  final Node _input1;
  final Node _input2;

  GreaterEqualImpl(Node input1, Node input2)
      : this._input1 = input1,
        this._input2 = input2,
        super([input1, input2]);

  @override
  void evaluate(Map<Node, dynamic> dependencyValues, NodeState state) {
    state.evaluation = dependencyValues[_input1] >= dependencyValues[_input2];
  }
}

class NotImpl extends NodeImpl implements Not {
  final Node _input;

  NotImpl(Node input)
      : this._input = input,
        super([input]);

  @override
  void evaluate(Map<Node, dynamic> dependencyValues, NodeState state) {
    state.evaluation = !dependencyValues[_input];
  }
}

class IfImpl extends NodeImpl implements If {
  final Node _ifInput;
  final Node _thenInput;
  final Node _elseInput;

  IfImpl(Node ifInput, Node thenInput, Node elseInput)
      : this._ifInput = ifInput,
        this._thenInput = thenInput,
        this._elseInput = elseInput,
        super([ifInput, thenInput, elseInput]);

  @override
  void evaluate(Map<Node, dynamic> dependencyValues, NodeState state) {
    state.evaluation = dependencyValues[_ifInput]
        ? dependencyValues[_thenInput]
        : dependencyValues[_elseInput];
  }
}

class OptimizerImpl extends NodeImpl implements Optimizer {
  final Node _input;

  OptimizerImpl(Node input)
      : this._input = input,
        super([input]);

  @override
  void evaluate(Map<Node, dynamic> dependencyValues, NodeState state) {
    state.evaluation = null;
  }
}
