#version 460 core

// Full-screen post effect played when our dash dies: a ring of refraction
// that expands from the impact point, with chromatic aberration on the
// ring, a short white flash and a soft vignette pulse.

#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;      // output size in pixels
uniform vec2 uCenter;    // impact point in pixels
uniform float uProgress; // 0 → 1 over the life of the wave
uniform float uStrength; // 1 = full death wave, smaller for light hits
uniform sampler2D uScene;

out vec4 fragColor;

void main() {
  vec2 frag = FlutterFragCoord().xy;
  vec2 uv = frag / uSize;

  float aspect = uSize.x / uSize.y;
  vec2 toPixel = frag - uCenter;
  float dist = length(toPixel);
  vec2 dir = dist > 0.0001 ? toPixel / dist : vec2(0.0);

  float maxRadius = length(uSize) * 0.75;
  // easeOutCubic so the wave starts fast and settles.
  float p = 1.0 - pow(1.0 - uProgress, 3.0);
  float radius = p * maxRadius;
  float width = mix(30.0, 140.0, p) * max(uSize.y / 1000.0, 0.5);
  float fade = 1.0 - uProgress;

  // 1 on the ring, 0 away from it, a little negative just inside so the
  // ring looks like a lens (pushes out, then pulls in).
  float x = (dist - radius) / width;
  float ring = exp(-x * x * 4.0) * sign(x + 0.0001) * -1.0;
  float amount = ring * fade * fade * uStrength * 0.045;

  // Offsets are measured in screen heights, so the wave looks round.
  vec2 toUv = uSize.y / uSize;
  vec2 offset = dir * amount * toUv;
  vec2 aberration = dir * toUv * (abs(amount) * 0.5 + 0.004 * fade * fade * uStrength);

  vec4 base = texture(uScene, uv - offset);
  vec4 red = texture(uScene, uv - offset - aberration);
  vec4 blue = texture(uScene, uv - offset + aberration);
  vec4 color = vec4(red.r, base.g, blue.b, base.a);
  // At the edge of the game (the letterbox around it is transparent) the
  // split channels would leave bright fringes, so fall back to the plain
  // sample there.
  color = mix(base, color, min(red.a, blue.a) * base.a);

  // Bright rim on the ring.
  float rim = exp(-x * x * 6.0) * fade * fade * uStrength;
  color.rgb += vec3(1.0, 0.95, 0.85) * rim * 0.18 * color.a;

  // White flash in the first frames.
  float flash = pow(fade, 10.0) * uStrength;
  color.rgb = mix(color.rgb, vec3(color.a), flash * 0.55);

  // Vignette that pulses in and out.
  vec2 c = uv - 0.5;
  float vignette = smoothstep(0.35, 0.85, length(c * vec2(aspect, 1.0) / max(aspect, 1.0)));
  color.rgb *= 1.0 - vignette * 0.35 * sin(uProgress * 3.14159) * uStrength;

  fragColor = color;
}
