#version 460 core

// A small, quick shockwave ring around the dash when it dies (in the spirit
// of Celeste's death burst): a crisp white ring that snaps outward and
// thins, with red/cyan color-split edges, a soft shadow just inside it and a
// bright pop at the center in the first frames.
//
// It's drawn in a square around the impact point only (uSize is that
// square), on top of the frame. It never reads the frame back, which on the
// web costs a GPU→CPU copy every frame.

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

  // Shadow just inside the ring, like a lens edge.
  float shadow = exp(-(x + 1.6) * (x + 1.6) * 3.0) * 0.18 * fade;
  color = over(vec4(0.0, 0.02, 0.06, 1.0) * shadow, color);

  // Color-split edges.
  float red = exp(-(x - 0.9) * (x - 0.9) * 6.0) * 0.45 * fade;
  float cyan = exp(-(x + 0.9) * (x + 0.9) * 6.0) * 0.45 * fade;
  color = over(vec4(1.0, 0.25, 0.4, 1.0) * red, color);
  color = over(vec4(0.25, 0.85, 1.0, 1.0) * cyan, color);

  // The crisp white ring.
  float ring = smoothstep(1.0, 0.55, abs(x)) * fade;
  color = over(vec4(1.0) * ring, color);

  // A bright pop at the center for the first frames.
  float pop = exp(-pow(dist / (maxRadius * 0.35), 2.0)) * pow(1.0 - uProgress, 6.0) * uStrength;
  color = over(vec4(1.0) * pop, color);

  fragColor = color;
}
