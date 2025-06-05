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

// 大理石のベインパターンを生成
float marbleVeins(vec2 uv) {
    // 基本的な波状パターン
    float pattern = sin(uv.x * 6.0 + uv.y * 2.0) * 0.5 + 0.5;
    
    // 複数の周波数で複雑な波を作成
    // pattern += sin(uv.x * 3.0 - uv.y * 4.0);
    // pattern += sin(uv.x * 8.0 + uv.y * 1.5);
    
    // ノイズで歪ませて自然な感じにする
    float distortion = fbm(uv * 6.0) * 0.8;
    pattern = sin((uv.x + distortion) * 5.0 + (uv.y + distortion * 0.5) * 2.0);
    
    // // より細かい歪みを追加
    // float fineDistortion = fbm(uv * 8.0) * 0.4;
    // pattern += sin((uv.x + fineDistortion) * 10.0 - uv.y * 3.0) * 0.3;
    
    return pattern * 0.5 + 0.5;
}

// 大理石の亀裂パターン
float marbleCracks(vec2 uv) {
    // 主要な亀裂
    float crack1 = abs(sin(uv.x * 3.0 + uv.y * 1.5 + fbm(uv * 2.0) * 2.0));
    crack1 = smoothstep(0.8, 1.0, crack1);
    
    // 細かい亀裂
    float crack2 = abs(sin(uv.x * 8.0 + uv.y * 4.0 + fbm(uv * 6.0) * 1.5));
    crack2 = smoothstep(0.9, 1.0, crack2);
    
    return max(crack1, crack2 * 0.5);
}

// 大理石の雲状パターン
float marbleClouds(vec2 uv) {
    // 大きな雲状のパターン
    float clouds = fbm(uv * 2.0);
    
    // 中程度の雲
    clouds += fbm(uv * 4.0) * 0.5;
    
    // 細かい雲
    clouds += fbm(uv * 8.0) * 0.25;
    
    return clouds;
}

// メイン大理石パターン生成
float marblePattern(vec2 uv) {
    // ベインパターン
    float veins = marbleVeins(uv);
    
    // 雲状パターン
    float clouds = marbleClouds(uv);
    
    // 亀裂パターン
    float cracks = marbleCracks(uv);
    
    // パターンを組み合わせ
    float marble = clouds * 0.6 + veins * 0.4;
    
    // 亀裂を強調
    marble = mix(marble, marble * 0.3, cracks);
    
    // 全体的なコントラストを調整
    marble = pow(marble, 0.8);
    
    return clamp(marble, 0.0, 1.0);
}

void main() {
    vec2 uv = vUv;
    
    // 大理石パターンを生成
    float marble = marblePattern(uv);
    
    // 大理石の色を定義（白系大理石）
    vec3 baseWhite = vec3(0.95, 0.94, 0.92);      // ベースの白色
    vec3 warmWhite = vec3(0.98, 0.96, 0.94);      // 温かい白
    vec3 coolGray = vec3(0.85, 0.87, 0.89);       // クールなグレー
    vec3 darkVein = vec3(0.4, 0.5, 0.6);          // 暗い血管色（青みがかったグレー）
    
    // 大理石の色を混合
    vec3 marbleColor;
    
    if (marble < 0.3) {
        // 暗い血管部分
        marbleColor = mix(darkVein, coolGray, marble / 0.3);
    } else if (marble < 0.7) {
        // 中間色
        marbleColor = mix(coolGray, baseWhite, (marble - 0.3) / 0.4);
    } else {
        // 明るい部分
        marbleColor = mix(baseWhite, warmWhite, (marble - 0.7) / 0.3);
    }
    
    // 微細な表面の質感を追加
    float surfaceNoise = noise(uv * 60.0) * 0.03;
    marbleColor += surfaceNoise;
    
    // 光沢感を演出するための微細な変化
    float specular = fbm(uv * 20.0) * 0.05;
    marbleColor += vec3(specular);
    
    // 少し青みがかった色調を追加（大理石の特徴）
    marbleColor += vec3(-0.01, -0.005, 0.01) * marble;
    
    gl_FragColor = vec4(marbleColor, 1.0);
}
