// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import "package:collection/collection.dart";

const _listEquality = const DeepCollectionEquality();

abstract class Quantity {}

class Scalar extends Quantity {
  final num value;

  Scalar(this.value);

  @override
  String toString() => value.toString();
}

class Vector extends Quantity {
  final List<num> _values;

  Vector(Iterable<num> values) : this._values = new List.from(values);

  Vector.filled(int length, num fill)
      : this._values = new List.filled(length, fill);

  Vector.generate(int length, num generator(int index))
      : this._values = new List.generate(length, generator);

  @override
  String toString() => _values.toString();
}

class Matrix extends Quantity {
  final List<int> _shape;
  final List _values;

  factory Matrix(List values) {
    var shape = _getShape(values);

    return new Matrix._internal(values, shape);
  }

  factory Matrix.filled(List<int> shape, num fill) {
    var values = _getFilled(shape, fill);

    return new Matrix._internal(values, shape);
  }

  factory Matrix.generate(List<int> shape, num generator(List<int> indices)) {
    var values = _getGenerate(shape, [], generator);

    return new Matrix._internal(values, shape);
  }

  Matrix._internal(this._values, this._shape);

  static List<int> _getShape(List values) {
    var shape = [values.length];
    var elementShape;
    for (var element in values) {
      var newElementShape = element is List ? _getShape(element) : [];
      if (elementShape != null) {
        if (!_listEquality.equals(newElementShape, elementShape)) {
          throw new ArgumentError.value(
              values.toString(), "shape", "Not valid shape");
        }
      } else {
        elementShape = newElementShape;
      }
    }
    shape.addAll(elementShape);
    return shape;
  }

  static List _getFilled(List<int> shape, num fill) {
    if (shape.length > 1) {
      var values = [];
      for (var i = 0; i < shape[0]; i++) {
        values.add(_getFilled(shape.sublist(1), fill));
      }
      return values;
    } else {
      return new List.filled(shape[0], fill);
    }
  }

  static List _getGenerate(List<int> shape, List<int> startIndices,
      num generator(List<int> indices)) {
    var indices = new List.from(startIndices);
    indices.length++;

    var values = [];
    if (shape.length > 1) {
      for (var i = 0; i < shape[0]; i++) {
        indices[indices.length - 1] = i;
        values.add(_getGenerate(shape.sublist(1), indices, generator));
      }
    } else {
      for (int i = 0; i < shape[0]; i++) {
        indices[indices.length - 1] = i;
        values.add(generator(indices));
      }
    }
    return values;
  }

  @override
  String toString() => "(${_shape.join(" x ")}): $_values";
}
