import { Elm } from "./Main.elm";
import "./Main.css";

import * as faker from "faker";
import * as asciichart from "asciichart";
import * as throttle from "lodash.throttle";
console.log("Throttle", throttle);

const app = Elm.Main.init({});
const padding = "      ";
const chartOptions = {
  height: 5,
  padding: padding,
  format: (x, i) => (padding + x.toFixed(1)).slice(-padding.length)
};
//
// Random number between min and max, inclusive of both min and max
function numberBetween(min, max) {
  return Math.floor(Math.random() * (max - min)) + min;
}

app.ports.fakerOutgoing.subscribe(count => {
  const messages = [];
  while (count > 0) {
    messages.push({
      name: faker.name.findName(),
      avatar: `/lazy/images/avatars/${numberBetween(1, 43)}.jpg`,
      message: faker.lorem.paragraph()
    });
    count--;
  }
  app.ports.fakerIncoming.send(messages);
});

app.ports.loggerOutgoing.subscribe(str => {
  console.log(str);
});

app.ports.sendReady.subscribe(() => {
  var viewChartElem = document.getElementById("view-chart");
  var diffChartElem = document.getElementById("diff-chart");
  var patchChartElem = document.getElementById("patch-chart");
  var frameChartElem = document.getElementById("frame-chart");
  var lazySuccessChartElem = document.getElementById("lazy-success-chart");
  var lazyFailureChartElem = document.getElementById("lazy-failure-chart");
  var MAX_SAMPLES = 100;
  var viewData = [];
  var diffData = [];
  var patchData = [];
  var frameData = [];
  var frameStart, frameEnd;

  var lazySuccessData = [0];
  var lazyFailureData = [0];
  var lazySuccesses = 0,
    lazyFailures = 0;

  var updateCharts = throttle(() => {
    viewChartElem.innerHTML = asciichart.plot(viewData, chartOptions);
    diffChartElem.innerHTML = asciichart.plot(diffData, chartOptions);
    patchChartElem.innerHTML = asciichart.plot(patchData, chartOptions);
    frameChartElem.innerHTML = asciichart.plot(frameData, chartOptions);
    lazyFailureChartElem.innerHTML = asciichart.plot(lazyFailureData, chartOptions);
    lazySuccessChartElem.innerHTML = asciichart.plot(lazySuccessData, chartOptions);
  }, 250);

  document.addEventListener("elm-view", event => {
    if (viewData.length >= MAX_SAMPLES) viewData.shift();
    viewData.push(event.detail);
  });
  document.addEventListener("elm-vdom-diff", event => {
    if (diffData.length >= MAX_SAMPLES) diffData.shift();
    diffData.push(event.detail);
  });
  document.addEventListener("elm-vdom-patch", event => {
    if (patchData.length >= MAX_SAMPLES) patchData.shift();
    patchData.push(event.detail);

    // view->diff->patch->update charts
    updateCharts();
  });
  document.addEventListener("elm-lazy-success", event => {
    if (lazySuccessData.length >= MAX_SAMPLES) lazySuccessData.shift();
    lazySuccesses++;
    lazySuccessData.push(lazySuccesses);
  });
  document.addEventListener("elm-lazy-failure", event => {
    if (lazyFailureData.length >= MAX_SAMPLES) lazyFailureData.shift();
    lazyFailures++;
    lazyFailureData.push(lazyFailures);
  });

  frameStart = performance.now();
  var lastFrameTime = 0;
  var smoothing = 10;
  function timeFrames() {
    frameEnd = performance.now();
    if (frameData.length >= MAX_SAMPLES) frameData.shift();
    var duration = frameEnd - frameStart;
    lastFrameTime += (duration * (duration - lastFrameTime)) / smoothing;
    frameData.push(duration);
    frameStart = frameEnd;
    requestAnimationFrame(timeFrames);
  }
  timeFrames();
});
