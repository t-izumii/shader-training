#ifdef GL_ES
precision mediump float;
#endif

varying vec2 vUv;
varying float vElevation;
uniform float uTime;
uniform vec2 uResolution;

// 改良版ノイズ関数
float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898,78.233))) * 43758.5453123);
}

// 2Dノイズ
float noise(vec2 st) {
    vec2 i = floor(st);
    vec2 f = fract(st);

    // 4つの角のランダム値
    float a = random(i);
    float b = random(i + vec2(1.0, 0.0));
    float c = random(i + vec2(0.0, 1.0));
    float d = random(i + vec2(1.0, 1.0));

    // より滑らかな補間
    vec2 u = f * f * f * (f * (f * 6.0 - 15.0) + 10.0);

    return mix(a, b, u.x) +
            (c - a)* u.y * (1.0 - u.x) +
            (d - b) * u.x * u.y;
}

// リッジノイズ - 山の尾根を生成
float ridge(float h, float offset) {
    h = abs(h);     // 絶対値を取る
    h = offset - h; // オフセットを適用
    h = h * h;      // 二乗して尖らせる
    return h;
}

#define OCTAVES 8
float ridgedMF(vec2 st) {
    float lacunarity = 2.0;
    float gain = 0.5;
    float offset = 0.9;
    float sum = 0.0;
    float freq = 1.0, amp = 0.5;
    float prev = 1.0;
    
    for(int i = 0; i < OCTAVES; i++) {
        float n = ridge(noise(st * freq), offset);
        sum += n * amp;
        sum += n * amp * prev;  // 前のオクターブの影響を加える
        prev = n;
        freq *= lacunarity;
        amp *= gain;
    }
    return sum;
}

float fbm(vec2 st) {
    float value = 0.0;
    float amplitude = 0.5;
    float frequency = 1.0;
    float lacunarity = 2.0;
    float gain = 0.5;
    
    for(int i = 0; i < OCTAVES; i++) {
        float n = noise(st * frequency);
        value += amplitude * n;
        frequency *= lacunarity;
        amplitude *= gain;
    }
    return value;
}

void main() {
    vUv = uv;
    vec3 pos = position;

    // アスペクト比の調整
    vec2 adjustedUv = vUv;
    adjustedUv.x *= uResolution.x / uResolution.y;

    // 基本地形の生成
    float scale = 4.0;
    float timeScale = 0.05;
    vec2 movement = vec2(uTime * timeScale);
    
    // リッジノイズと通常のFBMを組み合わせる
    float ridge1 = ridgedMF(adjustedUv * scale + movement);
    float ridge2 = ridgedMF((adjustedUv + 100.0) * scale * 2.0 + movement);
    float basic = fbm(adjustedUv * scale * 0.5 + movement);
    
    // 地形の組み合わせ
    float elevation = ridge1;
    elevation += ridge2 * 0.5;    // より小さな山々
    elevation += basic * 0.3;     // 起伏の追加
    
    // 高さの調整
    elevation = pow(elevation, 1.5);  // より急峻に
    float heightScale = 30.0;        // 高さスケール
    pos.z += elevation * heightScale;
    
    vElevation = elevation;
    gl_Position = projectionMatrix * modelViewMatrix * vec4(pos, 1.0);
}