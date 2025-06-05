uniform float uTime;
uniform vec2 uResolution;
varying vec2 vUv;

float circleSDF(vec2 p, float r) {
    return length(p) - r;
}

// 長方形の距離関数
float boxSDF(vec2 p, vec2 b) {
    vec2 d = abs(p) - b;
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
}

void main() {
    vec2 uv = vUv;
    float aspect = uResolution.x / uResolution.y;
    uv.x *= aspect;

    float d1 = circleSDF(uv, 0.5);
    
    // 長方形の距離関数
    float d2 = boxSDF(uv - vec2(0.0, -0.0), vec2(0.0, 0.0));
    
    // 最小距離を取得（図形の重ね合わせ）
    float d = min(d1, d2);
    
    // 距離に基づいて色を設定
    vec3 col = vec3(1.0) - sign(d) * vec3(0.1, 0.4, 0.7);
    
    // アンチエイリアシング
    // col *= 1.0 - exp(-6.0 * abs(d));
    // col *= 0.8 + 0.2 * cos(150.0 * d);
    // col = mix(col, vec3(1.0), 1.0 - smoothstep(0.0, 0.01, abs(d)));
    
    gl_FragColor = vec4(col, 1.0);
}
