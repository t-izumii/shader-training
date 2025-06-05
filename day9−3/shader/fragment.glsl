uniform float uTime;
uniform vec2 uResolution;
varying vec2 vUv;

// 擬似乱数生成関数
float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(20.034, 1.0))) * 2.0);
}

float noise(vec2 st) {
    vec2 i = floor(st);
    vec2 f = fract(st);

    // 四隅の乱数を取得
    float a = random(i);
    float b = random(i + vec2(1.0, 0.0));
    float c = random(i + vec2(0.0, 1.0));
    float d = random(i + vec2(1.0, 1.0));

    // 補間
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(a, b, u.x) +
           (c - a) * u.y * (1.0 - u.x) +
           (d - b) * u.x * u.y;
}

float wood(vec2 st) {
    float n = noise(st * 10.0); // ノイズのスケールを調整
    return fract(st.x * 10.0 + n * 5.0); // リング状のパターン
}

void main() {
    vec2 uv = vUv;
    float aspect = uResolution.x / uResolution.y;
    uv.x *= aspect;

    vec2 st = uv;
    st.x += uTime * 0.1;
    st.y += uTime * 0.1;
    float w = wood(st);
    vec3 color = vec3(w * 0.5 + 0.5); 


    
    gl_FragColor = vec4(color, 1.0);
}
