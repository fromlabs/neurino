// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import "dart:math";

import "../operation.dart";

import "node.dart";
import "container.dart";
import "variable.dart";
import "session.dart";

class BatchImpl extends BaseNodeImpl implements Batch {
  static const String _type = "batch";

  final List<BaseNodeImpl> _inputs;

  BatchImpl(this._inputs, {String id}) : super(id, _type) {
    _inputs.forEach((input) => checkInternalDependency(input));
  }

  @override
  calculateEvaluation() =>
      _inputs.map((input) => input.evaluate()).toList(growable: false);

  @override
  void evaluateLocalGradients() {
    // TODO to implement
    throw new UnimplementedError("TO IMPLEMENT");
  }

  @override
  void evaluateTargetGradients(gradient) {
    // TODO to implement
    throw new UnimplementedError("TO IMPLEMENT");
  }
}

class MemoryImpl extends BaseNodeImpl implements Memory {
  static const String _type = "memory";

  static const String _MEMORY_KEY = "_MEMORY";

  final BaseNodeImpl _input;
  final BaseNodeImpl _initial;

  MemoryImpl(input, initial, {String id})
      : this._input = toNode(input),
        this._initial = toNode(initial),
        super(id, _type) {
    checkInternalDependency(_input);
    checkInternalDependency(_initial);
  }

  @override
  void initializeState(NodeState newState, NodeState previousState) {
    if (previousState.contains(_MEMORY_KEY)) {
      newState[_MEMORY_KEY] = previousState[_MEMORY_KEY];
    }
  }

  @override
  calculateEvaluation() {
    try {
      return state.contains(_MEMORY_KEY)
          ? state[_MEMORY_KEY]
          : _initial.evaluate();
    } finally {
      state[_MEMORY_KEY] = _input.evaluate();
    }
  }

  @override
  void evaluateLocalGradients() {
    // TODO to implement
    throw new UnimplementedError("TO IMPLEMENT");
  }

  @override
  void evaluateTargetGradients(gradient) {
    // TODO to implement
    throw new UnimplementedError("TO IMPLEMENT");
  }
}

class AddImpl extends BaseNodeImpl implements Add {
  static const String _type = "add";

  final BaseNodeImpl _input1;
  final BaseNodeImpl _input2;

  AddImpl(input1, input2, {String id})
      : this._input1 = toNode(input1),
        this._input2 = toNode(input2),
        super(id, _type) {
    checkInternalDependency(_input1);
    checkInternalDependency(_input2);
  }

  @override
  calculateEvaluation() => _input1.evaluate() + _input2.evaluate();

  @override
  void evaluateLocalGradients() {
    _input1.propagateLocalGradients(1);
    _input2.propagateLocalGradients(1);
  }

  @override
  void evaluateTargetGradients(gradient) {
    _input1.propagateTargetGradients(gradient);
    _input2.propagateTargetGradients(gradient);
  }
}

class MulImpl extends BaseNodeImpl implements Mul {
  static const String _type = "mul";

  final BaseNodeImpl _input1;
  final BaseNodeImpl _input2;

  MulImpl(input1, input2, {String id})
      : this._input1 = toNode(input1),
        this._input2 = toNode(input2),
        super(id, _type) {
    checkInternalDependency(_input1);
    checkInternalDependency(_input2);
  }

  @override
  calculateEvaluation() => _input1.evaluate() * _input2.evaluate();

  @override
  void evaluateLocalGradients() {
    _input1.propagateLocalGradients(_input2.evaluation);
    _input2.propagateLocalGradients(_input1.evaluation);
  }

  @override
  void evaluateTargetGradients(gradient) {
    _input1.propagateTargetGradients(gradient);
    _input2.propagateTargetGradients(gradient);
  }
}

class DivImpl extends BaseNodeImpl implements Div {
  static const String _type = "div";

  final BaseNodeImpl _input1;
  final BaseNodeImpl _input2;

  DivImpl(input1, input2, {String id})
      : this._input1 = toNode(input1),
        this._input2 = toNode(input2),
        super(id, _type) {
    checkInternalDependency(_input1);
    checkInternalDependency(_input2);
  }

  @override
  calculateEvaluation() => _input1.evaluate() / _input2.evaluate();

  @override
  void evaluateLocalGradients() {
    _input1.propagateLocalGradients(1 / _input2.evaluation);
    _input2.propagateLocalGradients(
        -(_input1.evaluation / pow(_input2.evaluation, 2)));
  }

  @override
  void evaluateTargetGradients(gradient) {
    _input1.propagateTargetGradients(gradient);
    _input2.propagateTargetGradients(gradient);
  }
}

class NegateImpl extends BaseNodeImpl implements Negate {
  static const String _type = "negate";

  final BaseNodeImpl _input;

  NegateImpl(input, {String id})
      : this._input = toNode(input),
        super(id, _type) {
    checkInternalDependency(_input);
  }

  @override
  calculateEvaluation() => -_input.evaluate();

  @override
  void evaluateLocalGradients() {
    _input.propagateLocalGradients(-1);
  }

  @override
  void evaluateTargetGradients(gradient) {
    _input.propagateTargetGradients(state.targetGradient);
  }
}

class ExpImpl extends BaseNodeImpl implements Exp {
  static const String _type = "exp";

  final BaseNodeImpl _input;

  ExpImpl(input, {String id})
      : this._input = toNode(input),
        super(id, _type) {
    checkInternalDependency(_input);
  }

  @override
  calculateEvaluation() => exp(_input.evaluate());

  @override
  void evaluateLocalGradients() {
    _input.propagateLocalGradients(exp(_input.evaluate()));
  }

  @override
  void evaluateTargetGradients(gradient) {
    _input.propagateTargetGradients(state.targetGradient);
  }
}

class AbsImpl extends BaseNodeImpl implements Abs {
  static const String _type = "abs";

  final BaseNodeImpl _input;

  AbsImpl(input, {String id})
      : this._input = toNode(input),
        super(id, _type) {
    checkInternalDependency(_input);
  }

  @override
  calculateEvaluation() {
    num value = _input.evaluate();
    return value.abs();
  }

  @override
  void evaluateLocalGradients() {
    // TODO to implement
    throw new UnimplementedError("TO IMPLEMENT");
  }

  @override
  void evaluateTargetGradients(gradient) {
    // TODO to implement
    throw new UnimplementedError("TO IMPLEMENT");
  }
}

class MaxImpl extends BaseNodeImpl implements Max {
  static const String _type = "max";

  final BaseNodeImpl _input1;
  final BaseNodeImpl _input2;

  MaxImpl(input1, input2, {String id})
      : this._input1 = toNode(input1),
        this._input2 = toNode(input2),
        super(id, _type) {
    checkInternalDependency(_input1);
    checkInternalDependency(_input2);
  }

  @override
  calculateEvaluation() => max(_input1.evaluate(), _input2.evaluate());

  @override
  void evaluateLocalGradients() {
    // TODO to implement
    throw new UnimplementedError("TO IMPLEMENT");
  }

  @override
  void evaluateTargetGradients(gradient) {
    // TODO to implement
    throw new UnimplementedError("TO IMPLEMENT");
  }
}

class Loss2Impl extends BaseNodeImpl implements Loss2 {
  static const String _type = "loss2";

  final BaseNodeImpl _input1;
  final BaseNodeImpl _input2;

  Loss2Impl(input1, input2, {String id})
      : this._input1 = toNode(input1),
        this._input2 = toNode(input2),
        super(id, _type) {
    checkInternalDependency(_input1);
    checkInternalDependency(_input2);
  }

  @override
  calculateEvaluation() => pow(_input1.evaluate() - _input2.evaluate(), 2) / 2;

  @override
  void evaluateLocalGradients() {
    _input1.propagateLocalGradients(_input1.evaluation - _input2.evaluation);
    _input2.propagateLocalGradients(_input2.evaluation - _input1.evaluation);
  }

  @override
  void evaluateTargetGradients(gradient) {
    _input1.propagateTargetGradients(gradient);
    _input2.propagateTargetGradients(gradient);
  }
}

class GradientsEvaluateImpl extends BaseNodeImpl implements GradientsEvaluate {
  static const String _type = "gradients";

  final BaseNodeImpl _target;

  final num _learningRate;

  GradientsEvaluateImpl(target, {num learningRate, String id})
      : this._target = toNode(target),
        this._learningRate = learningRate,
        super(id, _type) {
    checkInternalDependency(_target);
  }

  @override
  calculateEvaluation() {
    _target.evaluate();

    _target.propagateLocalGradients();

    _target.propagateTargetGradients();

    defaultContainer.allVariables.forEach((VariableImpl variable) {
      // print("Gradient: $variable = ${variable.gradientEvaluation}");

      variable.updateEvaluation(
          variable.evaluation - _learningRate * variable.gradientEvaluation);
    });

    return true;
  }

  @override
  void evaluateLocalGradients() {
    // TODO to implement
    throw new UnimplementedError("TO IMPLEMENT");
  }

  @override
  void evaluateTargetGradients(gradient) {
    // TODO to implement
    throw new UnimplementedError("TO IMPLEMENT");
  }
}
