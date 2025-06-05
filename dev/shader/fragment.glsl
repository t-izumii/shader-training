uniform float uTime;
uniform vec2 uResolution;
varying vec2 vUv;

void main() {
    vec2 uv = vUv;
    float aspect = uResolution.x / uResolution.y;
    vec2 direction = normalize(vec2(1.0, 1.0)); // Direction of the gradient
    float gradient = dot(uv, direction);
    vec3 color = vec3(gradient);
    gl_FragColor = vec4(color, 1.0);
}
