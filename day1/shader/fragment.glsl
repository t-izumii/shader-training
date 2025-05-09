uniform float uTime;
varying vec2 vUv;

void main() {
    vec2 uv = vUv; // テクスチャ座標
    vec3 color = vec3(uv.x * sin(uTime), uv.y * sin(uTime), sin(uTime));
    gl_FragColor = vec4(color, 1.0);
}
