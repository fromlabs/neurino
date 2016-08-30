// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import "node.dart";

import "impl/node.dart";
import "impl/variable.dart";

typedef VariableInitializer();

abstract class Variable implements Node {
  factory Variable(VariableInitializer initialize, {String id}) =>
      new VariableImpl(initialize, id: id);
}

abstract class VariableUpdate implements Node {
  factory VariableUpdate(Variable variable, value, {String id}) =>
      new VariableUpdateImpl(variable, toNode(value), id: id);
}

abstract class AllVariableInitialize implements Node {
  factory AllVariableInitialize({String id}) =>
      new AllVariableInitializeImpl(id: id);
}
