// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import "dart:math";

import "../operation.dart";

import "node.dart";
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
      return state.contains(_MEMORY_KEY) ? state[_MEMORY_KEY] : _initial.evaluate();
    } finally {
      state[_MEMORY_KEY] = _input.evaluate();
    }
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
}

class GreaterEqualImpl extends BaseNodeImpl implements GreaterEqual {
  static const String _type = "greater_equal";

  final BaseNodeImpl _input1;
  final BaseNodeImpl _input2;

  GreaterEqualImpl(input1, input2, {String id})
      : this._input1 = toNode(input1),
        this._input2 = toNode(input2),
        super(id, _type) {
    checkInternalDependency(_input1);
    checkInternalDependency(_input2);
  }

  @override
  calculateEvaluation() => _input1.evaluate() >= _input2.evaluate();
}

class NotImpl extends BaseNodeImpl implements Not {
  static const String _type = "not";

  final BaseNodeImpl _input;

  NotImpl(input, {String id})
      : this._input = toNode(input),
        super(id, _type) {
    checkInternalDependency(_input);
  }

  @override
  calculateEvaluation() {
    bool value = _input.evaluate();
    return !value;
  }
}

class IfImpl extends BaseNodeImpl implements If {
  static const String _type = "if";

  final BaseNodeImpl _ifInput;
  final BaseNodeImpl _thenInput;
  final BaseNodeImpl _elseInput;

  IfImpl(ifInput, thenInput, elseInput, {String id})
      : this._ifInput = toNode(ifInput),
        this._thenInput = toNode(thenInput),
        this._elseInput = toNode(elseInput),
        super(id, _type) {
    checkInternalDependency(_ifInput);
    checkInternalDependency(_thenInput);
    checkInternalDependency(_elseInput);
  }

  @override
  calculateEvaluation() {
    bool value = _ifInput.evaluate();
    return value ? _thenInput.evaluate() : _elseInput.evaluate();
  }
}
