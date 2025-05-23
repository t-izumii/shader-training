uniform float uTime;
uniform vec2 uResolution;
varying vec2 vUv;

vec3 hash33(vec3 p) {
    p = vec3(dot(p, vec3(127.1, 311.7, 311.7)),
             dot(p, vec3(269.5, 183.3, 183.3)),
             dot(p, vec3(419.2, 371.9, 371.9)));
    return -1.0 + 2.0 * fract(sin(p) * 43758.5453123);
}

float noise(vec3 p) {
    vec3 i = floor(p);
    vec3 f = fract(p);
    vec3 u = f * f * (3.0 - 2.0 * f);
    return mix(mix(mix(dot(hash33(i + vec3(0.0, 0.0, 0.0)), f - vec3(0.0, 0.0, 0.0)),
                    dot(hash33(i + vec3(1.0, 0.0, 0.0)), f - vec3(1.0, 0.0, 0.0)), u.x),
                    mix(dot(hash33(i + vec3(0.0, 1.0, 0.0)), f - vec3(0.0, 1.0, 0.0)),
                        dot(hash33(i + vec3(1.0, 1.0, 0.0)), f - vec3(1.0, 1.0, 0.0)), u.x), u.y), u.z);
}

void main() {
    vec2 uv = vUv; // テクスチャ座標
    float n = noise(vec3(uv * 5.0, uTime));
    vec3 color = vec3(n);
    gl_FragColor = vec4(color, 1.0);
}
