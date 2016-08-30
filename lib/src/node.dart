// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import "impl/node.dart";

abstract class Node {
  String get id;

  bool get isEvaluated;

  get evaluation;
}

abstract class Constant implements Node {
  factory Constant(value, {String id}) => new ConstantImpl(value, id: id);
}

abstract class Composite implements Node {
  factory Composite(Map<String, Node> inputs,
          Node nodeFactory(Map<Node, CompositeInput> inputs),
          {String id}) =>
      new CompositeImpl(inputs, nodeFactory, id: id);
}

abstract class ModelInput implements Node {
  factory ModelInput({String id}) => new ModelInputImpl(id: id);
}

abstract class CompositeInput implements Node {
  factory CompositeInput(Node input, {String id}) =>
      new CompositeInputImpl(input, id: id);
}
