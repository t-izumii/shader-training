uniform float uTime;
uniform vec2 uResolution;
varying vec2 vUv;

float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

void main() {
    vec2 uv = vUv;
    float aspect = uResolution.x / uResolution.y;
    uv.x *= aspect;
    vec2 st = uv;
    st.x += uTime * 0.01;
    st.y += uTime * 0.01;
    float rnd = random(st);
    vec3 col = vec3(rnd, 0.5, 0.0);


    
    gl_FragColor = vec4(col, 0.0);
}
