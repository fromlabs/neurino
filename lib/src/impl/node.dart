// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import "dart:math";
import "../model_graph.dart";
import "../node.dart";

import "model_session.dart";

abstract class NodeImpl implements Node {
  final List<Node> _dependencies;

  final List<NodeImpl> _dependants = [];

  ModelGraph _graph;

  NodeImpl(this._dependencies);

  List<Node> get dependencies => _dependencies;

  bool get _isRegistered => _graph != null;

  void registerModelGraph(ModelGraph graph) {
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

  void registerModelGraph(ModelGraph graph) {
    for (var node in _internalNodes) {
      graph.register(node);
    }

    super.registerModelGraph(graph);
  }
}

class PlaceHolderNodeImpl extends NodeImpl implements PlaceHolderNode {
  static const String _HOLD_KEY = "_HOLD";

  PlaceHolderNodeImpl() : super([]);

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

class ConstantNodeImpl extends NodeImpl implements ConstantNode {
  final _value;

  ConstantNodeImpl(this._value) : super([]);

  @override
  void evaluate(Map<Node, dynamic> dependencyValues, NodeState state) {
    state.evaluation = _value;
  }
}

class VariableNodeImpl extends NodeImpl implements VariableNode {
  static const String _VAR_KEY = "_VAR";

  VariableNodeImpl() : super([]);

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

class BatchNodeImpl extends NodeImpl implements BatchNode {
  final List<Node> _inputs;

  BatchNodeImpl(List<Node> inputs)
      : this._inputs = inputs,
        super(inputs);

  @override
  void evaluate(Map<Node, dynamic> dependencyValues, NodeState state) {
    state.evaluation = dependencyValues;
  }
}

class AddNodeImpl extends NodeImpl implements AddNode {
  final Node _input1;
  final Node _input2;

  AddNodeImpl(Node input1, Node input2)
      : this._input1 = input1,
        this._input2 = input2,
        super([input1, input2]);

  @override
  void evaluate(Map<Node, dynamic> dependencyValues, NodeState state) {
    state.evaluation = dependencyValues[_input1] + dependencyValues[_input2];
  }
}

class MulNodeImpl extends NodeImpl implements MulNode {
  final Node _input1;
  final Node _input2;

  MulNodeImpl(Node input1, Node input2)
      : this._input1 = input1,
        this._input2 = input2,
        super([input1, input2]);

  @override
  void evaluate(Map<Node, dynamic> dependencyValues, NodeState state) {
    state.evaluation = dependencyValues[_input1] * dependencyValues[_input2];
  }
}

class MaxNodeImpl extends NodeImpl implements MaxNode {
  final Node _input1;
  final Node _input2;

  MaxNodeImpl(Node input1, Node input2)
      : this._input1 = input1,
        this._input2 = input2,
        super([input1, input2]);

  @override
  void evaluate(Map<Node, dynamic> dependencyValues, NodeState state) {
    state.evaluation =
        max(dependencyValues[_input1], dependencyValues[_input2]);
  }
}

class GreaterEqualNodeImpl extends NodeImpl implements GreaterEqualNode {
  final Node _input1;
  final Node _input2;

  GreaterEqualNodeImpl(Node input1, Node input2)
      : this._input1 = input1,
        this._input2 = input2,
        super([input1, input2]);

  @override
  void evaluate(Map<Node, dynamic> dependencyValues, NodeState state) {
    state.evaluation = dependencyValues[_input1] >= dependencyValues[_input2];
  }
}

class NotNodeImpl extends NodeImpl implements NotNode {
  final Node _input;

  NotNodeImpl(Node input)
      : this._input = input,
        super([input]);

  @override
  void evaluate(Map<Node, dynamic> dependencyValues, NodeState state) {
    state.evaluation = !dependencyValues[_input];
  }
}

class IfNodeImpl extends NodeImpl implements IfNode {
  final Node _ifInput;
  final Node _thenInput;
  final Node _elseInput;

  IfNodeImpl(Node ifInput, Node thenInput, Node elseInput)
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

class Loss1NodeImpl extends CompositeNodeImpl implements Loss1Node {
  factory Loss1NodeImpl(Node input1, Node input2) {
    var negate = new NegateNode(input2);
    var add = new AddNode(input1, negate);
    var loss1 = new AbsNode(add);

    return new Loss1NodeImpl._(loss1, [negate, add, loss1]);
  }

  Loss1NodeImpl._(Node main, List<Node> internalNodes)
      : super.internal(main, internalNodes);
}

class MemoryNodeImpl extends NodeImpl implements MemoryNode {
  static const String _MEM_KEY = "_MEM";

  final Node _input;
  final Node _initial;

  MemoryNodeImpl(Node input, Node initial)
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

class NegateNodeImpl extends NodeImpl implements NegateNode {
  final Node _input;

  NegateNodeImpl(Node input)
      : this._input = input,
        super([input]);

  @override
  void evaluate(Map<Node, dynamic> dependencyValues, NodeState state) {
    state.evaluation = -dependencyValues[_input];
  }
}

class AbsNodeImpl extends NodeImpl implements AbsNode {
  final Node _input;

  AbsNodeImpl(Node input)
      : this._input = input,
        super([input]);

  @override
  void evaluate(Map<Node, dynamic> dependencyValues, NodeState state) {
    num value = dependencyValues[_input];
    state.evaluation = value.abs();
  }
}

class VariableUpdateNodeImpl extends NodeImpl implements VariableUpdateNode {
  final VariableNode _variable;
  final Node _input;

  VariableUpdateNodeImpl(VariableNode variable, Node input)
      : this._variable = variable,
        this._input = input,
        super([variable, input]);

  VariableNode get variable => _variable;

  Node get input => _input;

  @override
  void evaluate(Map<Node, dynamic> dependencyValues, NodeState state) {
    state.evaluation = null;
  }
}

class OptimizerNodeImpl extends NodeImpl implements OptimizerNode {
  final Node _input;

  OptimizerNodeImpl(Node input)
      : this._input = input,
        super([input]);

  @override
  void evaluate(Map<Node, dynamic> dependencyValues, NodeState state) {
    state.evaluation = null;
  }
}
