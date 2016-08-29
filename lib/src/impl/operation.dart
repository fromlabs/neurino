// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import "dart:math";

import "../node.dart";
import "../operation.dart";

import "node.dart";
import "model_descriptor.dart";
import "model_state.dart";
import "session.dart";

class BatchImpl extends LocalNodeImpl implements Batch {
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

class MemoryImpl extends LocalNodeImpl implements Memory {
  static const String _type = "memory";

  static const String _MEM_KEY = "_MEM";

  final NodeImpl _input;
  final NodeImpl _initial;

  MemoryImpl(input, initial, {String id})
      : this._input = toNode(input),
        this._initial = toNode(initial),
        super(id, _type) {
    registerNodeDependency(_input);
    registerNodeDependency(_initial);
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

class AddImpl extends LocalNodeImpl implements Add {
  static const String _type = "add";

  final NodeImpl _input1;
  final NodeImpl _input2;

  AddImpl(input1, input2, {String id})
      : this._input1 = toNode(input1),
        this._input2 = toNode(input2),
        super(id, _type) {
    registerNodeDependency(_input1);
    registerNodeDependency(_input2);
  }

  @override
  calculateEvaluation(
          Map<NodeImpl, dynamic> dependencyValues, NodeState state) =>
      dependencyValues[_input1] + dependencyValues[_input2];
}

class MulImpl extends LocalNodeImpl implements Mul {
  static const String _type = "mul";

  final NodeImpl _input1;
  final NodeImpl _input2;

  MulImpl(input1, input2, {String id})
      : this._input1 = toNode(input1),
        this._input2 = toNode(input2),
        super(id, _type) {
    registerNodeDependency(_input1);
    registerNodeDependency(_input2);
  }

  @override
  calculateEvaluation(
          Map<NodeImpl, dynamic> dependencyValues, NodeState state) =>
      dependencyValues[_input1] * dependencyValues[_input2];
}

class NegateImpl extends LocalNodeImpl implements Negate {
  static const String _type = "negate";

  final NodeImpl _input;

  NegateImpl(input, {String id})
      : this._input = toNode(input),
        super(id, _type) {
    registerNodeDependency(_input);
  }

  @override
  calculateEvaluation(
          Map<NodeImpl, dynamic> dependencyValues, NodeState state) =>
      -dependencyValues[_input];
}

class AbsImpl extends LocalNodeImpl implements Abs {
  static const String _type = "abs";

  final NodeImpl _input;

  AbsImpl(input, {String id})
      : this._input = toNode(input),
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

class MaxImpl extends LocalNodeImpl implements Max {
  static const String _type = "max";

  final NodeImpl _input1;
  final NodeImpl _input2;

  MaxImpl(input1, input2, {String id})
      : this._input1 = toNode(input1),
        this._input2 = toNode(input2),
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

  factory Loss1Impl(input1, input2, {String id}) {
    var negate = new Negate(toNode(input2));
    var add = new Add(toNode(input1), negate);
    var main = new Abs(add);

    return new Loss1Impl._(main as NodeImpl, id);
  }

  Loss1Impl._(NodeImpl main, String id) : super.internal(main, id, _type);
}

class GreaterEqualImpl extends LocalNodeImpl implements GreaterEqual {
  static const String _type = "greater_equal";

  final NodeImpl _input1;
  final NodeImpl _input2;

  GreaterEqualImpl(input1, input2, {String id})
      : this._input1 = toNode(input1),
        this._input2 = toNode(input2),
        super(id, _type) {
    registerNodeDependency(_input1);
    registerNodeDependency(_input2);
  }

  @override
  calculateEvaluation(
          Map<NodeImpl, dynamic> dependencyValues, NodeState state) =>
      dependencyValues[_input1] >= dependencyValues[_input2];
}

class NotImpl extends LocalNodeImpl implements Not {
  static const String _type = "not";

  final Node _input;

  NotImpl(input, {String id})
      : this._input = toNode(input),
        super(id, _type) {
    registerNodeDependency(_input);
  }

  @override
  calculateEvaluation(
          Map<NodeImpl, dynamic> dependencyValues, NodeState state) =>
      !dependencyValues[_input];
}

class IfImpl extends LocalNodeImpl implements If {
  static const String _type = "if";

  final NodeImpl _ifInput;
  final NodeImpl _thenInput;
  final NodeImpl _elseInput;

  IfImpl(ifInput, thenInput, elseInput, {String id})
      : this._ifInput = toNode(ifInput),
        this._thenInput = toNode(thenInput),
        this._elseInput = toNode(elseInput),
        super(id, _type) {
    registerNodeDependency(_ifInput);
    registerNodeDependency(_thenInput);
    registerNodeDependency(_elseInput);
  }

  @override
  calculateEvaluation(
          Map<NodeImpl, dynamic> dependencyValues, NodeState state) =>
      dependencyValues[_ifInput]
          ? dependencyValues[_thenInput]
          : dependencyValues[_elseInput];
}

class OptimizerImpl extends SessionNodeImpl implements Optimizer {
  static const String _type = "optimizer";

  final NodeImpl _input;

  OptimizerImpl(NodeImpl input, {String id})
      : this._input = input,
        super(id, _type) {
    registerNodeDependency(_input);
  }

  @override
  calculateEvaluation(SessionImpl session) {
    // TODO to implement ottimizzazione loss
    throw new UnimplementedError("TO IMPLEMENT");
  }
}
