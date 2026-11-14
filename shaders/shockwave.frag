#version 460 core

// The rim of the death shockwave: a faint, thin highlight on the wave front
// with a soft shadow just inside it, like the edge of a lens. The bending
// and blurring of the scene behind it is done in ScreenFx; this only adds
// the edge so the wave reads clearly.
//
// It's drawn in a square around the impact point only (uSize is that
// square).

#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;      // the square's size in pixels (2 x max radius)
uniform float uProgress; // 0 → 1 over the life of the wave
uniform float uStrength; // 1 = full death wave

out vec4 fragColor;

// Premultiplied "over".
vec4 over(vec4 top, vec4 bottom) {
  return top + bottom * (1.0 - top.a);
}

void main() {
  vec2 frag = FlutterFragCoord().xy;
  float maxRadius = uSize.x * 0.5;
  float dist = length(frag - uSize * 0.5);

  // Fast out, then settles: most of the growth happens in the first third.
  float p = 1.0 - pow(1.0 - uProgress, 4.0);
  float radius = mix(0.15, 1.0, p) * maxRadius * 0.92;
  // Starts thick, ends as a hairline.
  float width = mix(0.16, 0.02, uProgress) * maxRadius;
  float fade = (1.0 - uProgress) * uStrength;

  float x = (dist - radius) / width; // 0 on the ring

  vec4 color = vec4(0.0);

  // Soft shadow just inside the front.
  float shadow = exp(-(x + 1.8) * (x + 1.8) * 2.5) * 0.10 * fade;
  color = over(vec4(0.0, 0.02, 0.06, 1.0) * shadow, color);

  // Faint highlight on the front.
  float rim = smoothstep(1.0, 0.3, abs(x)) * 0.22 * fade;
  color = over(vec4(1.0) * rim, color);

  fragColor = color;
}
