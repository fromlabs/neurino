// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import "dart:io";
import "dart:async";

import "package:neurino/neurino.dart";

main() async {
  var dataset = await loadData();

  var network = buildNetwork();

  new Session(network["model"])
    ..asDefault((session) {
      session.run(new AllVariablesInitialize());

      var inputsSet = dataset["inputs"];
      var outputsSet = dataset["outputs"];

      for (var i = 0; i < inputsSet.length; i++) {
        var inputs = inputsSet[i];
        var output = outputsSet[i];

        var feed = {network["real_output"]: output};

        for (var l = 0; l < inputs.length; l++) {
          feed[network["inputs"][l]] = inputs[l];
        }

        // session.run(network["optimizer"], inputs: feed);
        session.run(network["loss"], inputs: feed);

        print("Prediction: ${network["outputs"][0].evaluation} [$output]");
        print("Loss: ${network["loss"].evaluation}");
      }
    });
}

Future<Map> loadData() async {
  var f = new File("data/pima-indians-diabetes.data");

  var lines = await f.readAsLines();

  var inputs = [];
  var outputs = [];
  for (var line in lines) {
    var nums = line.split(",").map((s) => num.parse(s)).toList();
    inputs.add(nums.sublist(0, 8));
    outputs.add(nums[8]);
  }

  return {"inputs": inputs, "outputs": outputs};
}

Map buildNetwork() {
  var realOutput;
  var inputLayer;
  var outputLayer;
  var loss;
  var optimizer;
  var model = new Model()
    ..asDefault(() {
      realOutput = new ModelInput(id: "real_output");
      inputLayer = buildInputLayer(8, id: "input");
      outputLayer = buildSigmoidDenseLayer(1, inputLayer, id: "output");
      loss = new BinaryCrossEntropyLoss(realOutput, outputLayer[0], id: "loss");
      optimizer =
          new GradientsEvaluate(loss, learningRate: 0.01, id: "optimizer");
    });
  return {
    "model": model,
    "inputs": inputLayer,
    "outputs": outputLayer,
    "real_output": realOutput,
    "loss": loss,
    "optimizer": optimizer
  };
}

List<Node> buildInputLayer(int neuronsCount, {String id}) => new List.generate(
    neuronsCount, (i) => new ModelInput(id: id != null ? "$id/$i" : null));

List<Node> buildReluDenseLayer(int neuronsCount, List<Node> inputs,
    {String id}) {
  var potentials = _buildDenseLayer(neuronsCount, inputs);

  var activations = [];
  var i = 0;
  for (var potential in potentials) {
    activations.add(new Relu(potential, id: id != null ? "$id/$i" : null));
  }
  return activations;
}

List<Node> buildSigmoidDenseLayer(int neuronsCount, List<Node> inputs,
    {String id}) {
  var potentials = _buildDenseLayer(neuronsCount, inputs);

  var activations = [];
  var i = 0;
  for (var potential in potentials) {
    activations.add(new Sigmoid(potential, id: id != null ? "$id/$i" : null));
  }
  return activations;
}

List<Node> _buildDenseLayer(int neuronsCount, List<Node> inputs, {String id}) {
  var potentials = [];
  for (var i = 0; i < neuronsCount; i++) {
    var xwSum = new Constant(0);
    for (var x in inputs) {
      var w = new Variable(() => 0.01);
      xwSum = new Add(new Mul(x, w), xwSum);
    }
    var b = new Variable(() => 0.01);
    potentials.add(new Add(xwSum, b));
  }
  return potentials;
}
