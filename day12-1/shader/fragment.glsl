uniform float uTime;
uniform vec2 uResolution;
varying vec2 vUv;

// ノイズ関数
float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

float noise(vec2 st) {
    vec2 i = floor(st);
    vec2 f = fract(st);
    
    float a = random(i);
    float b = random(i + vec2(1.0, 0.0));
    float c = random(i + vec2(0.0, 1.0));
    float d = random(i + vec2(1.0, 1.0));
    
    vec2 u = f * f * (3.0 - 2.0 * f);
    
    return mix(
        mix(a, b, u.x),
        mix(c, d, u.x),
        u.y
    );
}

// フラクタルノイズ（FBM）
float fbm(vec2 st) {
    float value = 0.0;
    float amplitude = 0.5;
    
    for (int i = 0; i < 6; i++) {
        value += amplitude * noise(st);
        st *= 2.0;
        amplitude *= 0.5;
    }
    return value;
}

// 木目パターンの生成
float woodGrain(vec2 uv) {
    // 年輪の中心点（少し偏心させる）
    vec2 center = vec2(0.2, 0.5);
    
    // 中心からの距離
    float dist = distance(uv, center);
    
    // 基本的な年輪パターン
    float rings = sin(dist * 15.0) * 0.5 + 0.5;
    
    // ノイズで年輪を歪ませる
    float distortion = fbm(uv * 4.0) * 0.3;
    rings = sin((dist + distortion) * 15.0) * 0.5 + 0.5;
    
    // 縦方向の木目（木材の繊維方向）
    float verticalGrain = fbm(vec2(uv.x * 10.0, uv.y * 100.0)) * 0.4;
    
    // 木材の節（ノット）を追加
    vec2 knotCenter = vec2(0.7, 0.3);
    float knotDist = distance(uv, knotCenter);
    float knot = smoothstep(0.15, 0.05, knotDist) * 0.8;
    
    // 全体を組み合わせ
    float woodPattern = rings * 0.6 + verticalGrain * 0.3 + knot * -0.5;
    
    // 自然な変化を追加
    woodPattern += fbm(uv * 8.0) * 0.1;
    
    return clamp(woodPattern, 0.0, 1.0);
}

void main() {
    vec2 uv = vUv;
    
    // 木目パターンを生成
    float wood = woodGrain(uv);
    
    // 木の色合いを定義
    vec3 lightWood = vec3(0.85, 0.65, 0.45);  // 明るい木の色（ベージュ）
    vec3 midWood = vec3(0.6, 0.4, 0.25);      // 中間色（茶色）
    vec3 darkWood = vec3(0.3, 0.2, 0.12);     // 暗い木の色（濃い茶）
    
    // 木目の濃淡に応じて色を混合
    vec3 woodColor;
    if (wood < 0.4) {
        // 暗い部分
        woodColor = mix(darkWood, midWood, wood / 0.4);
    } else {
        // 明るい部分
        woodColor = mix(midWood, lightWood, (wood - 0.4) / 0.6);
    }
    
    // 温かみのある色調を追加
    woodColor += vec3(0.05, 0.02, 0.0) * sin(wood * 3.14159);
    
    // 微細な表面の質感
    float surface = noise(uv * 40.0) * 0.05;
    woodColor += surface;
    
    gl_FragColor = vec4(woodColor, 1.0);
}
