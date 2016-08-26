// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import "node.dart";

import "impl/model_descriptor.dart";

abstract class ModelDescriptor {
  factory ModelDescriptor() => new ModelDescriptorImpl();

  void asDefault(void scopedRunnable());
}
