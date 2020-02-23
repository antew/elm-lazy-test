import { Elm } from "./Main.elm";
import "./Main.css";

import * as faker from "faker";
import * as asciichart from "asciichart";

const app = Elm.Main.init({});
const frameTimes = [];
let frameStart, frameEnd;
const chartOptions = {
  height: 5,
  padding: '     '
}
//
// Random number between min and max, inclusive of both min and max
function numberBetween(min, max) {
  return Math.floor(Math.random() * (max - min)) + min;
}

app.ports.fakerOutgoing.subscribe(() => {
  app.ports.fakerIncoming.send({
    name: faker.name.findName(),
    avatar: `/static/images/avatars/${numberBetween(1, 43)}.jpg`,
    message: faker.lorem.paragraph()
  });
});

app.ports.loggerOutgoing.subscribe(str => {
  console.log(str)
});

frameStart = performance.now();
function timeFrames() {
  frameEnd = performance.now();
  frameTimes.push(frameEnd - frameStart);
  frameStart = frameEnd;

  var frameChartElem = document.getElementById("frame-chart");
  var frameData = frameTimes.slice(-45);
  var frameChart = asciichart.plot(frameData, chartOptions);
  if (frameChart) frameChartElem.innerHTML = frameChart;

  requestAnimationFrame(timeFrames)
}
timeFrames();

setInterval(() => {
  if (!window.elm_performance) return;
  var viewChartElem = document.getElementById("view-chart");
  var diffChartElem = document.getElementById("diff-chart");
  var patchChartElem = document.getElementById("patch-chart");

  const points = -45;
  var viewData = window.elm_performance.view.slice(points);
  var diffData = window.elm_performance.vdom_diff.slice(points);
  var patchData = window.elm_performance.vdom_patch.slice(points);

  var viewChart = asciichart.plot(viewData, chartOptions);
  var diffChart = asciichart.plot(diffData, chartOptions);
  var patchChart = asciichart.plot(patchData, chartOptions);

  /*
  console.log("-- View Function ---");
  console.log(viewChart);
  console.log("-- Virtual DOM Diffing Function ---");
  console.log(diffChart);
  console.log("-- Virtual DOM Patching Function ---");
  console.log(patchChart);
  console.log("-- Frame Time Chart---");
  console.log(frameChart);
  */

  if (viewChart) viewChartElem.innerHTML = viewChart;
  if (diffChart) diffChartElem.innerHTML = diffChart;
  if (patchChart) patchChartElem.innerHTML = patchChart;
  // if (frameChart) frameChartElem.innerHTML = frameChart;
}, 1000);
