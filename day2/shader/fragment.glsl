uniform float uTime;
uniform vec2 uResolution;
varying vec2 vUv;

void main() {
    vec2 uv = vUv;
    float aspect = uResolution.x / uResolution.y;
    
    // 中心座標
    vec2 center = vec2(0.5, 0.5);
    float dist = distance(uv, center);

    float wave = sin(dist * 8.0 - uTime * 3.0);

    float pattern = (wave + 1.0) * 0.5;

    vec3 color = vec3(  pattern);
    
    gl_FragColor = vec4(color, 1.0);
}
