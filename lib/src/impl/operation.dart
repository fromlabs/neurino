// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import "dart:math";

import "../node.dart";
import "../operation.dart";

import "node.dart";
import "model_state.dart";
import "session.dart";

class ConstantNodeImpl extends EvaluationNodeImpl implements Constant {
  static const String _type = "constant";

  final _value;

  ConstantNodeImpl(this._value, {String id}) : super(id, _type);

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

class BatchImpl extends EvaluationNodeImpl implements Batch {
  static const String _type = "batch";

  final List<NodeImpl> _inputs;

  BatchImpl(this._inputs, {String id}) : super(id, _type) {
    _inputs.forEach((dependency) => registerNodeDependency(dependency));
  }

  @override
  calculateEvaluation(
          Map<NodeImpl, dynamic> dependencyValues, NodeState state) =>
      dependencyValues;
}

class MemoryImpl extends EvaluationNodeImpl implements Memory {
  static const String _type = "memory";

  static const String _MEM_KEY = "_MEM";

  final NodeImpl _input;
  final NodeImpl _initial;

  MemoryImpl(NodeImpl input, NodeImpl initial, {String id})
      : this._input = input,
        this._initial = initial,
        super(id, _type) {
    registerNodeDependency(input);
    registerNodeDependency(initial);
  }

  @override
  void initializeState(NodeState newState, NodeState previousState) {
    if (previousState.contains(_MEM_KEY)) {
      newState.set(_MEM_KEY, previousState.get(_MEM_KEY));
    }
  }

  @override
  calculateEvaluation(
      Map<NodeImpl, dynamic> dependencyValues, NodeState state) {
    try {
      return state.contains(_MEM_KEY)
          ? state.get(_MEM_KEY)
          : dependencyValues[_initial];
    } finally {
      state.set(_MEM_KEY, dependencyValues[_input]);
    }
  }
}

class AddImpl extends EvaluationNodeImpl implements Add {
  static const String _type = "add";

  final NodeImpl _input1;
  final NodeImpl _input2;

  AddImpl(NodeImpl input1, NodeImpl input2, {String id})
      : this._input1 = input1,
        this._input2 = input2,
        super(id, _type) {
    registerNodeDependency(_input1);
    registerNodeDependency(_input2);
  }

  @override
  calculateEvaluation(
          Map<NodeImpl, dynamic> dependencyValues, NodeState state) =>
      dependencyValues[_input1] + dependencyValues[_input2];
}

class MulImpl extends EvaluationNodeImpl implements Mul {
  static const String _type = "mul";

  final NodeImpl _input1;
  final NodeImpl _input2;

  MulImpl(NodeImpl input1, NodeImpl input2, {String id})
      : this._input1 = input1,
        this._input2 = input2,
        super(id, _type) {
    registerNodeDependency(_input1);
    registerNodeDependency(_input2);
  }

  @override
  calculateEvaluation(
          Map<NodeImpl, dynamic> dependencyValues, NodeState state) =>
      dependencyValues[_input1] * dependencyValues[_input2];
}

class NegateImpl extends EvaluationNodeImpl implements Negate {
  static const String _type = "negate";

  final NodeImpl _input;

  NegateImpl(NodeImpl input, {String id})
      : this._input = input,
        super(id, _type) {
    registerNodeDependency(_input);
  }

  @override
  calculateEvaluation(
          Map<NodeImpl, dynamic> dependencyValues, NodeState state) =>
      -dependencyValues[_input];
}

class AbsImpl extends EvaluationNodeImpl implements Abs {
  static const String _type = "abs";

  final NodeImpl _input;

  AbsImpl(NodeImpl input, {String id})
      : this._input = input,
        super(id, _type) {
    registerNodeDependency(_input);
  }

  @override
  calculateEvaluation(
      Map<NodeImpl, dynamic> dependencyValues, NodeState state) {
    num value = dependencyValues[_input];
    return value.abs();
  }
}

class MaxImpl extends EvaluationNodeImpl implements Max {
  static const String _type = "max";

  final NodeImpl _input1;
  final NodeImpl _input2;

  MaxImpl(NodeImpl input1, NodeImpl input2, {String id})
      : this._input1 = input1,
        this._input2 = input2,
        super(id, _type) {
    registerNodeDependency(_input1);
    registerNodeDependency(_input2);
  }

  @override
  calculateEvaluation(
          Map<NodeImpl, dynamic> dependencyValues, NodeState state) =>
      max(dependencyValues[_input1], dependencyValues[_input2]);
}

class Loss1Impl extends CompositeNodeImpl implements Loss1 {
  static const String _type = "loss1";

  factory Loss1Impl(NodeImpl input1, NodeImpl input2, {String id}) {
    var negate = new Negate(input2);
    var add = new Add(input1, negate);
    var main = new Abs(add);

    return new Loss1Impl._(main as NodeImpl, id);
  }

  Loss1Impl._(NodeImpl main, String id) : super.internal(main, id, _type);
}

class GreaterEqualImpl extends EvaluationNodeImpl implements GreaterEqual {
  static const String _type = "greater_equal";

  final NodeImpl _input1;
  final NodeImpl _input2;

  GreaterEqualImpl(NodeImpl input1, NodeImpl input2, {String id})
      : this._input1 = input1,
        this._input2 = input2,
        super(id, _type);

  @override
  calculateEvaluation(
          Map<NodeImpl, dynamic> dependencyValues, NodeState state) =>
      dependencyValues[_input1] >= dependencyValues[_input2];
}

class NotImpl extends EvaluationNodeImpl implements Not {
  static const String _type = "not";

  final Node _input;

  NotImpl(Node input, {String id})
      : this._input = input,
        super(id, _type);

  @override
  calculateEvaluation(
          Map<NodeImpl, dynamic> dependencyValues, NodeState state) =>
      !dependencyValues[_input];
}

class IfImpl extends EvaluationNodeImpl implements If {
  static const String _type = "if";

  final NodeImpl _ifInput;
  final NodeImpl _thenInput;
  final NodeImpl _elseInput;

  IfImpl(NodeImpl ifInput, NodeImpl thenInput, NodeImpl elseInput, {String id})
      : this._ifInput = ifInput,
        this._thenInput = thenInput,
        this._elseInput = elseInput,
        super(id, _type);

  @override
  calculateEvaluation(
          Map<NodeImpl, dynamic> dependencyValues, NodeState state) =>
      dependencyValues[_ifInput]
          ? dependencyValues[_thenInput]
          : dependencyValues[_elseInput];
}

class OptimizerImpl extends ActionNodeImpl implements Optimizer {
  static const String _type = "optimizer";

  final NodeImpl _input;

  OptimizerImpl(NodeImpl input, {String id})
      : this._input = input,
        super(id, _type);

  @override
  calculateEvaluation(SessionImpl session) {
    // TODO to implement ottimizzazione loss
    throw new UnimplementedError("TO IMPLEMENT");
  }
}
