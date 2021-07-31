#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;

// to draw the rectangle, one way to think is to draw/fill sides, i.e left,
// right, top, bottom sides and the left out part becomes rectangle
float rectShape(vec2 position, vec2 scale) {
  // Without this line, scale.x is describing the distance the rectangle is from the left and right boundaries of the window
  // and scale.y is describing the distance from the top and bottom boundaries of the window.
  // So if this line were ommitted a larger scale would actually shrink the box.
  // This line makes scale actually describe the size of the box.
  // What is we plug in 0.0 for scale? Then we get 0.5 - 0.0 * 0.5 which equals 0.5. Then the left and right sides of the box
  // are both start half way from the left and right sides of the screen respectively, making the box have a size of 0.
  // If we plug in 1.0 for scale we get 0.5 - 1.0 * 0.5 which equals 0.0. Then the left/right/top/bottom sides of the box start directly at
  // the left/right/top/bottom of the screen, filling the entire window. The equation we have is a linear equation so we know that this will change linearly
  // between these two extreme values.
  // So the summary of what this line does is: a scale of 0.0 is a box scaled down to a point, a scale of 1.0 fills the entire screen, and anything inbetween
  // is a linear interpolation of that.
  scale = vec2(0.5) - scale * 0.5;
  // If the particular position.x that we're looking at is greater than scale.x, make shaper.x 1.0, otherwise make it 0.0.
  // Similarly if position.y greater than scale.y, make shaper.y 1.0, otherwise make it 0.0.
  vec2 shaper = vec2(step(scale.x, position.x), step(scale.y, position.y));
  // Remember that scale actually means the distance from a particular side of the window. So 1.0 - position.x means the distance away from the right side
  // of the window instead of the left side. Similarly 1.0 - position.y means the distance away from the top of the window instead of the bottom.
  // Since we're multiplying this by the previous value of shaper, and the only possible values of shaper.x and shaper.y are either 1.0 or 0.0, we are effectively
  // doing an "AND" binary operation. So at this point, shaper.x will only be 1.0 if position.x is a distance of at least scale.x away from both the left AND the right
  // side of the screen. Same thing for shaper.y.
  shaper *= vec2(step(scale.x, 1.0 - position.x), step(scale.y, 1.0 - position.y));
  // Multiplication is again indicative of an "AND" operation. This is saying that we return 1.0 if position is a distance of greater than scale away
  // from the tops and sides of the screens. This results in a rectangle.
  return shaper.x * shaper.y;
}

void main(){
  vec2 position = gl_FragCoord.xy / u_resolution;
  vec3 color = vec3(0.0);
  float rectangle = rectShape(position, vec2(0.2, 0.2));
  color = vec3(rectangle);
  gl_FragColor = vec4(color, 1.0);
}
