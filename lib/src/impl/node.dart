// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import "dart:async";

import "../node.dart";

import "container.dart";
import "session.dart";

BaseNodeImpl toNode(value) =>
    value is BaseNodeImpl ? value : new Constant(value);

abstract class BaseNodeImpl implements Node {
  final String id;

  final BaseContainerImpl _container;

  BaseNodeImpl(String id, String type)
      : this._container = defaultContainer,
        this.id = id ?? defaultContainer.createNewId(type) {
    _container.registerNode(this);
  }

  void checkParentDependency(BaseNodeImpl dependency) {
    if (dependency._container != _container.parent) {
      throw new ArgumentError.value(
          dependency, "dependency", "Not a parent dependency");
    }
  }

  void checkInternalDependency(BaseNodeImpl dependency) {
    if (dependency._container != _container) {
      throw new ArgumentError.value(dependency.id, "dependency",
          "Not a dependency of the same container");
    }
  }

  void initializeState(NodeState newState, NodeState previousState) {}

  calculateEvaluation() {
    throw new UnsupportedError("Evaluation");
  }

  @override
  bool get isEvaluated => state?.isEvaluated ?? false;

  @override
  get evaluation {
    if (!isEvaluated) {
      throw new StateError("Node $this not evaluated");
    }

    return state.evaluation;
  }

  void updateEvaluation(value) {
    if (state == null) {
      throw new StateError("Session not runned yet");
    } else if (isEvaluated) {
      throw new StateError("Node $this already evaluated");
    }

    state.evaluation = value;
  }

  evaluate() {
    if (!isEvaluated) {
      updateEvaluation(calculateEvaluation());
    }

    return evaluation;
  }

  NodeState get state => defaultSession?.getNodeState(this);

  @override
  String toString() => "\"$id\"";
}

class ConstantImpl extends BaseNodeImpl implements Constant {
  static const String _type = "constant";

  final _value;

  ConstantImpl(this._value, {String id}) : super(id, _type);

  @override
  bool get isEvaluated => true;

  @override
  get evaluation => _value;

  @override
  calculateEvaluation() {
    throw new UnsupportedError("Constant calculation");
  }

  @override
  void updateEvaluation(value) {
    throw new UnsupportedError("Constant update");
  }
}

class CompositeImpl extends BaseNodeImpl
    with BaseContainerImpl
    implements Composite {
  static const String _type = "composite";

  final BaseContainerImpl parent;

  final Map<BaseNodeImpl, CompositeInputImpl> _inputs = {};

  BaseNodeImpl _output;

  CompositeImpl(Map<String, BaseNodeImpl> inputs,
      BaseNodeImpl nodeFactory(Map<BaseNodeImpl, CompositeInputImpl> inputs),
      {String id})
      : this.parent = defaultContainer,
        super(id, _type) {
    asDefault(() {
      var compositeInputs = _toCompositeInputs(inputs);
      var output = nodeFactory(compositeInputs);

      checkCompositeDependency(output);

      this._inputs.addAll(compositeInputs);
      _output = output;
    });
  }

  static Map<BaseNodeImpl, CompositeInputImpl> _toCompositeInputs(
          Map<String, BaseNodeImpl> inputs) =>
      new Map.fromIterable(inputs.keys,
          key: (id) => inputs[id],
          value: (id) => new CompositeInput(inputs[id], id: id));

  void checkCompositeDependency(BaseNodeImpl dependency) {
    if (dependency._container != this) {
      throw new ArgumentError.value(
          dependency, "dependency", "Not a composite dependency");
    }
  }

  @override
  calculateEvaluation() => _output.evaluate();
}

class ModelInputImpl extends BaseNodeImpl implements ModelInput {
  static const String _type = "model-input";

  ModelInputImpl({String id}) : super(id, _type);

  @override
  get evaluation {
    if (!isEvaluated) {
      throw new StateError("Model input $this not specified");
    }

    return super.evaluation;
  }

  @override
  calculateEvaluation() {
    throw new StateError("Model input $this not specified");
  }
}

class CompositeInputImpl extends BaseNodeImpl implements CompositeInput {
  static const String _type = "composite-input";

  final BaseNodeImpl _input;

  CompositeInputImpl(this._input, {String id}) : super(id, _type) {
    checkParentDependency(_input);
  }

  @override
  calculateEvaluation() => _input.evaluate();
}
