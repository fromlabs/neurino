// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import "impl/node.dart";

abstract class Node {}

abstract class PlaceHolder implements Node {
  factory PlaceHolder() => new PlaceHolderImpl();
}

abstract class Variable implements Node {
  factory Variable() => new VariableImpl();
}

abstract class VariableUpdateNode implements Node {
  factory VariableUpdateNode(Variable variable, Node node) =>
      new VariableUpdateImpl(variable, node);
}

abstract class Constant implements Node {
  factory Constant(value) => new ConstantNodeImpl(value);
}

class Batch implements Node {
  factory Batch(List<Node> nodes) => new BatchImpl(nodes);
}

abstract class Memory implements Node {
  factory Memory(Node node1, Node node2) => new MemoryImpl(node1, node2);
}

abstract class Add implements Node {
  factory Add(Node node1, Node node2) => new AddImpl(node1, node2);
}

abstract class Mul implements Node {
  factory Mul(Node node1, Node node2) => new MulImpl(node1, node2);
}

abstract class Negate implements Node {
  factory Negate(Node node) => new NegateImpl(node);
}

abstract class Abs implements Node {
  factory Abs(Node node) => new AbsImpl(node);
}

abstract class Max implements Node {
  factory Max(Node node1, Node node2) => new MaxImpl(node1, node2);
}

abstract class Loss1 implements Node {
  factory Loss1(Node node1, Node node2) => new Loss1Impl(node1, node2);
}

abstract class GreaterEqual implements Node {
  factory GreaterEqual(Node node1, Node node2) =>
      new GreaterEqualImpl(node1, node2);
}

abstract class Not implements Node {
  factory Not(Node node) => new NotImpl(node);
}

abstract class If implements Node {
  factory If(Node ifNode, Node thenNode, Node elseNode) =>
      new IfImpl(ifNode, thenNode, elseNode);
}

abstract class Optimizer implements Node {
  factory Optimizer(Node node) => new OptimizerImpl(node);
}
