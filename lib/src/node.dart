// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import "impl/node.dart";

abstract class Node {}

abstract class PlaceHolderNode implements Node {
  factory PlaceHolderNode() => new PlaceHolderNodeImpl();
}

abstract class ConstantNode implements Node {
  factory ConstantNode(value) => new ConstantNodeImpl(value);
}

abstract class VariableNode implements Node {
  factory VariableNode() => new VariableNodeImpl();
}

abstract class VariableUpdateNode implements Node {
  factory VariableUpdateNode(VariableNode variable, Node node) =>
      new VariableUpdateNodeImpl(variable, node);
}

class BatchNode implements Node {
  factory BatchNode(List<Node> nodes) => new BatchNodeImpl(nodes);
}

abstract class AddNode implements Node {
  factory AddNode(Node node1, Node node2) => new AddNodeImpl(node1, node2);
}

abstract class MulNode implements Node {
  factory MulNode(Node node1, Node node2) => new MulNodeImpl(node1, node2);
}

abstract class Loss1Node implements Node {
  factory Loss1Node(Node node1, Node node2) => new Loss1NodeImpl(node1, node2);
}

abstract class OptimizerNode implements Node {
  factory OptimizerNode(Node node) => new OptimizerNodeImpl(node);
}

abstract class MemoryNode implements Node {
  factory MemoryNode(Node node1, Node node2) =>
      new MemoryNodeImpl(node1, node2);
}

abstract class NegateNode implements Node {
  factory NegateNode(Node node) => new NegateNodeImpl(node);
}

abstract class AbsNode implements Node {
  factory AbsNode(Node node) => new AbsNodeImpl(node);
}

abstract class MaxNode implements Node {
  factory MaxNode(Node node1, Node node2) => new MaxNodeImpl(node1, node2);
}

abstract class GreaterEqualNode implements Node {
  factory GreaterEqualNode(Node node1, Node node2) =>
      new GreaterEqualNodeImpl(node1, node2);
}

abstract class NotNode implements Node {
  factory NotNode(Node node) => new NotNodeImpl(node);
}

abstract class IfNode implements Node {
  factory IfNode(Node ifNode, Node thenNode, Node elseNode) =>
      new IfNodeImpl(ifNode, thenNode, elseNode);
}
