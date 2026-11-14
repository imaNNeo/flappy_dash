#version 460 core

// A procedural sparkle burst drawn where a point was scored: a thin ring,
// eight star rays and a soft glow, tinted with the dash color.
// No textures, so it costs only the small rect it is drawn in.

#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;      // rect size in pixels (square)
uniform float uProgress; // 0 → 1
uniform vec4 uColor;     // premultiplied tint
uniform float uSeed;     // rotates the rays so each burst differs

out vec4 fragColor;

void main() {
  vec2 frag = FlutterFragCoord().xy;
  vec2 p = (frag / uSize) * 2.0 - 1.0; // -1..1
  float d = length(p);
  float a = atan(p.y, p.x) + uSeed;

  float t = uProgress;
  float ease = 1.0 - pow(1.0 - t, 3.0);
  float fade = 1.0 - t;

  // Expanding ring, thick at first and thinning as it grows.
  float radius = ease * 0.8;
  float thickness = mix(0.14, 0.03, ease);
  float ring = smoothstep(thickness, thickness * 0.4, abs(d - radius)) * fade;

  // Four long and four short star rays that shoot out and thin.
  float longRays = pow(abs(cos(a * 2.0)), 40.0);
  float shortRays = pow(abs(sin(a * 2.0)), 40.0) * 0.6;
  float rays = max(longRays, shortRays);
  float rayLen = mix(0.3, 1.0, ease) * (longRays > shortRays ? 1.0 : 0.7);
  float rayMask = smoothstep(rayLen, rayLen * 0.3, d) * smoothstep(0.08, 0.22, d);
  float star = rays * rayMask * fade * fade * 1.6;

  // Core glow.
  float glow = exp(-d * d * 10.0) * pow(fade, 2.0);

  float alpha = clamp(ring + star + glow, 0.0, 1.0);
  // Saturated color on the ring, white-hot rays and core, so it reads on the
  // bright sky too.
  vec3 deep = uColor.rgb * 0.8;
  vec3 tint = mix(deep, vec3(1.0), clamp(star + glow * 0.8, 0.0, 1.0));
  fragColor = vec4(tint * alpha, alpha);
}
