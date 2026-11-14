#version 460 core

// Full-screen overlay played when our dash dies: a ring of light that
// expands from the impact point with color-split edges (red outside, cyan
// inside, like chromatic aberration) and a soft shadow just inside it, so it
// reads like a refracting lens. Plus a short white flash and a vignette
// pulse.
//
// It doesn't sample the frame: reading the frame back costs a GPU→CPU copy
// and a new GL context on the web (CanvasKit), which made deaths stutter.
// Drawing it on top is a single cheap full-screen pass.

#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;      // output size in pixels
uniform vec2 uCenter;    // impact point in pixels
uniform float uProgress; // 0 → 1 over the life of the wave
uniform float uStrength; // 1 = full death wave

out vec4 fragColor;

// Premultiplied "over".
vec4 over(vec4 top, vec4 bottom) {
  return top + bottom * (1.0 - top.a);
}

void main() {
  vec2 frag = FlutterFragCoord().xy;
  float scale = max(uSize.y / 1000.0, 0.5);

  float dist = length(frag - uCenter);
  float maxRadius = length(uSize) * 0.75;
  float p = 1.0 - pow(1.0 - uProgress, 3.0); // easeOutCubic
  float radius = p * maxRadius;
  float width = mix(26.0, 110.0, p) * scale;
  float fade = (1.0 - uProgress) * (1.0 - uProgress) * uStrength;

  float x = (dist - radius) / width; // 0 on the ring

  vec4 color = vec4(0.0);

  // Vignette that pulses in and out.
  vec2 c = frag / uSize - 0.5;
  float aspect = uSize.x / uSize.y;
  float vignette = smoothstep(0.35, 0.85, length(c * vec2(aspect, 1.0) / max(aspect, 1.0)));
  float vig = vignette * 0.35 * sin(uProgress * 3.14159) * uStrength;
  color = over(vec4(0.0, 0.0, 0.0, vig), color);

  // Shadow just inside the ring.
  float shadow = exp(-(x + 0.9) * (x + 0.9) * 5.0) * 0.16 * fade;
  color = over(vec4(0.0, 0.02, 0.06, 1.0) * shadow, color);

  // Color-split edges.
  float red = exp(-(x - 0.45) * (x - 0.45) * 14.0) * 0.35 * fade;
  float cyan = exp(-(x + 0.45) * (x + 0.45) * 14.0) * 0.35 * fade;
  color = over(vec4(1.0, 0.25, 0.35, 1.0) * red, color);
  color = over(vec4(0.2, 0.85, 1.0, 1.0) * cyan, color);

  // Bright rim.
  float rim = exp(-x * x * 10.0) * 0.6 * fade;
  color = over(vec4(1.0, 0.97, 0.9, 1.0) * rim, color);

  // White flash in the first frames.
  float flash = pow(1.0 - uProgress, 10.0) * 0.55 * uStrength;
  color = over(vec4(1.0) * flash, color);

  fragColor = color;
}
