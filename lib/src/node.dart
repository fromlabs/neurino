// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import "impl/node.dart";

abstract class Node {}

abstract class Constant implements Node {
  factory Constant(value, {String id}) => new ConstantImpl(value, id: id);
}

abstract class Input implements Node {
  factory Input({String id}) => new InputImpl(id: id);
}

abstract class Variable implements Node {
  factory Variable({String id}) => new VariableImpl(id: id);
}

abstract class VariableUpdate implements Node {
  factory VariableUpdate(Variable variable, value, {String id}) =>
      new VariableUpdateImpl(variable, value, id: id);
}
