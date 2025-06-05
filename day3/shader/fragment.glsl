uniform float uTime;
uniform vec2 uResolution;
varying vec2 vUv;

void main() {
    vec2 uv = vUv;
    float aspect = uResolution.x / uResolution.y;
    uv.x *= aspect;

    vec2 center = vec2(0.5 * aspect, 0.5);
    vec2 toCenter = uv - center;

    float dist = length(toCenter);

    vec2 direction = normalize(vec2(.5, .5));

    vec2 test = normalize(vec2(1.0, 1.0));

    float gradient = dot(uv, direction);

    vec3 color = vec3(gradient);
    gl_FragColor = vec4(color, 1.0);
}

