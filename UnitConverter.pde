final float meterFootRatio = 0.3048f; //one foot is ... meter

final color COLOR_RED = #F24405;
final color COLOR_ORANGE = #FA7F08;
final color COLOR_BLUE = #22BABB;
final color COLOR_DARK_BLUE = #348888;
final color COLOR_DARK_PURPLE = #12011c;
final color COLOR_TEXT = color(13, 6, 18);

final color[] PALETTE_1 = {#323673, #33A6A6, #F25041, #F29544};
final color[] PALETTE_2 = {#D90404, #F25C05, #078C03, #05C7F2};
final color[] PALETTE_3 = {COLOR_RED, COLOR_ORANGE, COLOR_BLUE, COLOR_DARK_BLUE};

//Order: °C, °F, m, ft
final color[][] PALETTES = {
  {#323673, #33A6A6, #F25041, #F29544},
  {#D90404, #F25C05, #078C03, #05C7F2},
  {#B484D9, #F596FA, #8698D9, #BDE4FF},
  {#FFAAA5, #FF8B94, #A8E6CF, #DCEDC1},
  {#2F3B7B, #655A88, #F28F6B, #D95F5F}
};
color[] currentPalette = PALETTES[int(random(0, PALETTES.length))];

float meterDist = 10.0f;
float celsiusTemp = 37.0f;
boolean shiftPressed = false;

String[] postShaderSource = {}

PShader postShader;

void setup() {
  size(400, 400, P2D);

  postShader = loadShader("shaders/crt.glsl");
  postShader.set("screenSize", width, height);
}

void draw() {
  boolean isTemp = mouseY < height/2;
  boolean isLeft = mouseX < width/2;

  drawLabelRect("°C", currentPalette[0], isTemp && isLeft, isTemp, 0, 0, width/2, height/2);
  drawLabelRect("°F", currentPalette[1], isTemp && !isLeft, isTemp, width/2, 0, width/2, height/2);
  drawLabelRect("METER", currentPalette[2], !isTemp && isLeft, !isTemp, 0, height/2, width/2, height/2);
  drawLabelRect("FEET", currentPalette[3], !isTemp && !isLeft, !isTemp, width/2, height/2, width/2, height/2);

  strokeWeight(2);
  stroke(0);
  line(0, height/2, width, height/2);
  line(width/2, 0, width/2, height);

  String displayString;
  if (isTemp) {
    displayString = String.valueOf(roundToDecimals(isLeft ? celsiusTemp : celsiusToFahrenheit(celsiusTemp), 2));
    displayString += isLeft ? " °C" : " °F";
  } else {
    displayString = String.valueOf(roundToDecimals(isLeft ? meterDist : meterToFeet(meterDist), 2));
    displayString += isLeft ? " m" : " ft";
  }

  fill(255);
  float textWidth = max(textWidth(displayString) + 20, 120);
  rect((width - textWidth)/2, height/2 - 25, textWidth, 50);

  fill(COLOR_TEXT);
  text(displayString, width/2, (height+22)/2);

  postShader.set("time", millis()*0.1f);
  filter(postShader);
}

void mouseDragged() {
  boolean isTemp = mouseY < height/2;
  boolean isLeft = mouseX < width/2;

  boolean controlPressed = keyPressed && keyCode == CONTROL;
  boolean altPressed = keyPressed && keyCode == ALT;

  float dragChange = (mouseX - pmouseX) * (controlPressed ? 0.5f : 0.1f) * (altPressed ? 0.1f : 1.0f);

  if (isTemp) {
    if (!isLeft) {
      celsiusTemp = fahrenheitToCelsius(celsiusToFahrenheit(celsiusTemp) + dragChange);
    } else {
      celsiusTemp += dragChange;
    }
    if (controlPressed) {
      celsiusTemp = isLeft ? round(celsiusTemp) : fahrenheitToCelsius(round(celsiusToFahrenheit(celsiusTemp)));
    }
  } else {
    meterDist += dragChange * (isLeft ? 1.0f : meterFootRatio);
    if (controlPressed) {
      meterDist = isLeft ? round(meterDist) : feetToMeter(round(meterToFeet(meterDist)));
    }
  }
}

void drawLabelRect(String label, color background, boolean selected, boolean active, int x, int y, int sX, int sY) {
  noStroke();

  fill(mixColorMult(background, COLOR_DARK_PURPLE, active ? 0.0f : 0.8f));
  //fill(PImage::blend(background, COLOR_DARK_PURPLE, active ? 0.0 : 0.6));
  //fill(lerpColor(background, COLOR_DARK_PURPLE, active ? 0.0 : 0.6));
  rect(x, y, sX, sY);

  textSize(32);
  fill(COLOR_TEXT, selected ? 255 : 50);
  textAlign(CENTER);
  text(label, x + sX/2, y + sY/2 + textAscent()/2);
}

color mixColorMult(color c1, color c2, float mix) {
  int a1 = (c1 >> 24) & 0xFF;
  int r1 = (c1 >> 16) & 0xFF;
  int g1 = (c1 >> 8) & 0xFF;
  int b1 = c1 & 0xFF;

  int a2 = (c2 >> 24) & 0xFF;
  int r2 = (c2 >> 16) & 0xFF;
  int g2 = (c2 >> 8) & 0xFF;
  int b2 = c2 & 0xFF;

  return lerpColor(c1, color(r1*r2/255, g1*g2/255, b1*b2/255, a1*a2/255), mix);
}

float celsiusToFahrenheit(float x) {
  return x * 9/5 + 32;
}

float fahrenheitToCelsius(float x) {
  return (x - 32) * 5/9;
}

float meterToFeet(float x) {
  return x * (1/meterFootRatio);
}

float feetToMeter(float x) {
  return x * meterFootRatio;
}

float roundToDecimals(float x, int decimals) {
  return round(x * pow(10, decimals)) / pow(10, decimals);
}
