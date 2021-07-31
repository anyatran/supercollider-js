#ifdef GL_ES
precision mediump float;
#endif

// useful to normalize things to 0.0 to 1.0
uniform vec2 u_resolution;

float circleShape(vec2 position, float radius) {
  return step(radius, length(position - vec2(0.5)));
}

// taking the distance from the edges of the canvas to the center of the screen, outputs a gradient,
// and the step functions draws anything above the value to 1.0 and anything below the value to 0.0.
void main() {
  vec2 position = gl_FragCoord.xy / u_resolution;
  vec3 color = vec3(0.0);
  float circle = circleShape(position, 0.3);
  color = vec3(circle);
  gl_FragColor = vec4(color, 1.0);
}
