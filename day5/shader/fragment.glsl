uniform float uTime;
uniform vec2 uResolution;
varying vec2 vUv;

void main() {
    vec2 uv = vUv;
    float aspect = uResolution.x / uResolution.y;
    uv.x *= aspect;

    // float stripe = mod(uv.x * 10.0, 1.0);
    // float stripe = fract(uv.x * 10.0);
    // float stripe = floor(uv.x * 10.0) / 10.0;
    // stripe = step(0.5, stripe);

    float small = mod(uv.x * 10.0, 1.0);
    float large = mod(uv.x * 100.0, 1.0);

    float stripe = step(0.5, small) * step(0.8, large);


    vec3 color = vec3(stripe);
    gl_FragColor = vec4(color, 1.0);
}
