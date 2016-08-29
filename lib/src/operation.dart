// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import "node.dart";

import "impl/operation.dart";

class Batch implements Node {
  factory Batch(List<Node> nodes, {String id}) => new BatchImpl(nodes);
}

abstract class Memory implements Node {
  factory Memory(node1, node2, {String id}) =>
      new MemoryImpl(node1, node2, id: id);
}

abstract class Add implements Node {
  factory Add(node1, node2, {String id}) =>
      new AddImpl(node1, node2, id: id);
}

abstract class Mul implements Node {
  factory Mul(node1, node2, {String id}) =>
      new MulImpl(node1, node2, id: id);
}

abstract class Negate implements Node {
  factory Negate(node, {String id}) => new NegateImpl(node, id: id);
}

abstract class Abs implements Node {
  factory Abs(node, {String id}) => new AbsImpl(node, id: id);
}

abstract class Max implements Node {
  factory Max(node1, node2, {String id}) =>
      new MaxImpl(node1, node2, id: id);
}

abstract class Loss1 implements Node {
  factory Loss1(node1, node2, {String id}) =>
      new Loss1Impl(node1, node2, id: id);
}

abstract class GreaterEqual implements Node {
  factory GreaterEqual(node1, node2, {String id}) =>
      new GreaterEqualImpl(node1, node2, id: id);
}

abstract class Not implements Node {
  factory Not(node, {String id}) => new NotImpl(node, id: id);
}

abstract class If implements Node {
  factory If(ifNode, thenNode, elseNode, {String id}) =>
      new IfImpl(ifNode, thenNode, elseNode, id: id);
}

abstract class Optimizer implements Node {
  factory Optimizer(Node node, {String id}) => new OptimizerImpl(node, id: id);
}
