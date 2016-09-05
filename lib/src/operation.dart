// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import "node.dart";

import "impl/operation.dart";

abstract class Batch implements Node {
  factory Batch(List<Node> inputs, {String id}) => new BatchImpl(inputs);
}

abstract class Memory implements Node {
  factory Memory(input, initial, {String id}) =>
      new MemoryImpl(input, initial, id: id);
}

abstract class Add implements Node {
  factory Add(input1, input2, {String id}) =>
      new AddImpl(input1, input2, id: id);
}

abstract class Mul implements Node {
  factory Mul(input1, input2, {String id}) =>
      new MulImpl(input1, input2, id: id);
}

abstract class Div implements Node {
  factory Div(input1, input2, {String id}) =>
      new DivImpl(input1, input2, id: id);
}

abstract class Negate implements Node {
  factory Negate(input, {String id}) => new NegateImpl(input, id: id);
}

abstract class Exp implements Node {
  factory Exp(input, {String id}) => new ExpImpl(input, id: id);
}

abstract class Abs implements Node {
  factory Abs(input, {String id}) => new AbsImpl(input, id: id);
}

abstract class Max implements Node {
  factory Max(input1, input2, {String id}) =>
      new MaxImpl(input1, input2, id: id);
}

abstract class Relu implements Node {
  factory Relu(input, {String id}) => new ReluImpl(input, id: id);
}

abstract class Sigmoid implements Node {
  factory Sigmoid(input, {String id}) => new SigmoidImpl(input, id: id);
}

abstract class Loss2 implements Node {
  factory Loss2(input1, input2, {String id}) =>
      new Loss2Impl(input1, input2, id: id);
}

abstract class BinaryCrossEntropyLoss implements Node {
  factory BinaryCrossEntropyLoss(input1, input2, {String id}) =>
      new BinaryCrossEntropyLossImpl(input1, input2, id: id);
}

abstract class GradientsEvaluate implements Node {
  factory GradientsEvaluate(target, {num learningRate: 1, String id}) =>
      new GradientsEvaluateImpl(target, learningRate: learningRate, id: id);
}
