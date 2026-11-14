#version 460 core

// Swirling vortex behind a dash's spawn portal (multiplayer).

#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;   // rect size in pixels (square)
uniform float uTime;  // seconds
uniform vec4 uColor;  // premultiplied tint

out vec4 fragColor;

void main() {
  vec2 frag = FlutterFragCoord().xy;
  vec2 p = (frag / uSize) * 2.0 - 1.0;
  float d = length(p);
  float a = atan(p.y, p.x);

  // Spiral arms that twist more toward the center.
  float swirl = sin(a * 3.0 + 6.0 / (d + 0.25) - uTime * 6.0);
  float arms = smoothstep(0.1, 0.9, swirl * 0.5 + 0.5);

  float disc = smoothstep(1.0, 0.75, d);
  float core = smoothstep(0.45, 0.0, d);
  float rim = smoothstep(0.08, 0.0, abs(d - 0.88)) * (0.6 + 0.4 * sin(uTime * 8.0 + a * 6.0));

  float alpha = clamp(disc * (0.35 + 0.45 * arms) + rim * 0.8, 0.0, 1.0);
  vec3 col = mix(uColor.rgb * 0.6, vec3(1.0), core * 0.8 + rim * 0.4);
  fragColor = vec4(col * alpha, alpha);
}
