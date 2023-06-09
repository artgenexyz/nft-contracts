
let dna;

function setup() {
  createCanvas(600, 600);
  background(30);
  colorMode(HSB, 360, 100, 100, 100);
  strokeWeight(3);
  noLoop();
  dna = Math.floor(fxrand() * 10000);
  noiseSeed(dna);
}

function draw() {
  let step = 20;
  let noiseStep = 0.03;

  // Vertical lines
  for (let x = 0; x < width; x += step) {
    let y1 = fxrand() * (height + step) - step;
    let y2 = height;
    let x1 = x + (fxrand() * step / 2) - (step / 4);
    let x2 = x + (fxrand() * step / 2) - (step / 4);

    x1 += noise(x1 * noiseStep, frameCount * noiseStep) * 20 - 10;
    x2 += noise(x2 * noiseStep, frameCount * noiseStep) * 20 - 10;

    let c = color(fxrand() * 360, 80, 90);
    stroke(c);
    line(x1, y1, x2, y2);
  }

  // Horizontal lines
  for (let y = 0; y < height; y += step) {
    let x1 = fxrand() * (width + step) - step;
    let x2 = width;
    let y1 = y + (fxrand() * step / 2) - (step / 4);
    let y2 = y + (fxrand() * step / 2) - (step / 4);

    y1 += noise(frameCount * noiseStep, y1 * noiseStep) * 20 - 10;
    y2 += noise(frameCount * noiseStep, y2 * noiseStep) * 20 - 10;

    let c = color(fxrand() * 360, 80, 90);
    stroke(c);
    line(x1, y1, x2, y2);
  }

  fxpreview();
}


