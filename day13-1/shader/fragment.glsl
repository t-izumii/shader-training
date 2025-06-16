#ifdef GL_ES
precision mediump float;
#endif

// ユニフォーム変数
uniform float uTime;
uniform vec2 uResolution;
uniform vec2 uMouse;

// 波紋パラメータ
uniform float uSpeed;
uniform float uFrequency;
uniform float uAmplitude;
uniform float uDamping;
uniform float uDistortion;

// 波紋データ（最大20個に増加）
uniform int uRippleCount;
uniform float uRippleCenters[40];  // 最大20個の波紋 x 2（x,y座標）
uniform float uRippleTimes[20];    // 各波紋の開始時間
uniform float uRippleIntensities[20]; // 各波紋の強度

varying vec2 vUv;

// アスペクト比を考慮した距離計算
float distanceWithAspect(vec2 uv1, vec2 uv2) {
    float aspect = uResolution.x / uResolution.y;
    vec2 diff = uv1 - uv2;
    diff.x *= aspect;  // X軸をアスペクト比で調整
    return length(diff);
}

// ランダム関数
float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

// 単一の波紋を計算
float calculateRipple(vec2 uv, vec2 center, float startTime, float intensity) {
    float currentTime = uTime;
    float elapsedTime = currentTime - startTime;
    
    // 波紋の寿命（3秒に短縮して流れるような効果）
    if (elapsedTime < 0.0 || elapsedTime > 3.0) {
        return 0.0;
    }
    
    // アスペクト比を考慮した中心からの距離
    float dist = distanceWithAspect(uv, center);
    
    // 波の伝播半径
    float waveRadius = elapsedTime * uSpeed;
    
    // 波面の幅
    float waveWidth = 0.08; // 少し狭くして美しい輪郭
    
    // 波面からの距離
    float waveFront = abs(dist - waveRadius);
    
    // 波面の範囲外は0
    if (waveFront > waveWidth) {
        return 0.0;
    }
    
    // 波面内での強度
    float frontIntensity = 1.0 - (waveFront / waveWidth);
    frontIntensity = smoothstep(0.0, 1.0, frontIntensity);
    
    // 正弦波の計算
    float wave = sin(dist * uFrequency - elapsedTime * uSpeed * uFrequency);
    
    // 距離による減衰
    float distanceAttenuation = 1.0 / (1.0 + dist * uDamping);
    
    // 時間による減衰（より緩やか）
    float timeAttenuation = exp(-elapsedTime * 0.3);
    
    // すべての要素を組み合わせ
    return wave * uAmplitude * intensity * frontIntensity * distanceAttenuation * timeAttenuation;
}

// すべての波紋を合成
float calculateAllRipples(vec2 uv) {
    float totalRipple = 0.0;
    
    // 最大20個の波紋をチェック
    for (int i = 0; i < 20; i++) {
        if (i >= uRippleCount) break;
        
        vec2 center = vec2(uRippleCenters[i * 2], uRippleCenters[i * 2 + 1]);
        float startTime = uRippleTimes[i];
        float intensity = uRippleIntensities[i];
        
        totalRipple += calculateRipple(uv, center, startTime, intensity);
    }
    
    return totalRipple;
}

// 波紋による歪みを計算
vec2 calculateDistortion(vec2 uv) {
    float epsilon = 0.001;
    
    // 中央の波紋値
    float center = calculateAllRipples(uv);
    
    // 周囲の値でサンプリング
    float right = calculateAllRipples(uv + vec2(epsilon, 0.0));
    float up = calculateAllRipples(uv + vec2(0.0, epsilon));
    
    // 勾配計算
    vec2 gradient = vec2(right - center, up - center) / epsilon;
    
    return gradient * uDistortion;
}

// 背景パターン（水面のような）
vec3 generateBackground(vec2 uv) {
    // アスペクト比を考慮したパターン
    float aspect = uResolution.x / uResolution.y;
    vec2 adjustedUV = uv;
    adjustedUV.x *= aspect;
    
    // 基本的な水面パターン
    float pattern1 = sin(adjustedUV.x * 20.0 + uTime * 2.0) * 0.1;
    float pattern2 = sin(adjustedUV.y * 15.0 + uTime * 1.5) * 0.1;
    float pattern3 = sin((adjustedUV.x + adjustedUV.y) * 10.0 + uTime) * 0.05;
    
    float combinedPattern = pattern1 + pattern2 + pattern3;
    
    // 水面のような青い色
    vec3 deepWater = vec3(0.0, 0.2, 0.4);
    vec3 lightWater = vec3(0.2, 0.6, 0.8);
    
    return mix(deepWater, lightWater, combinedPattern + 0.5);
}

// リフレクション効果
vec3 calculateReflection(vec2 uv, vec2 distortedUV) {
    // 簡単な空の反射を模擬
    float skyPattern = smoothstep(0.3, 0.7, distortedUV.y);
    vec3 skyColor = mix(vec3(0.6, 0.8, 1.0), vec3(1.0, 1.0, 1.0), skyPattern);
    
    // 太陽の反射（アスペクト比考慮）
    vec2 sunPos = vec2(0.7, 0.8);
    float sunDist = distanceWithAspect(distortedUV, sunPos);
    float sunReflection = exp(-sunDist * 10.0) * 0.5;
    
    return skyColor + vec3(sunReflection);
}

void main() {
    vec2 uv = vUv;
    
    // アスペクト比補正
    float aspect = uResolution.x / uResolution.y;
    uv.x *= aspect;

    vec2 center = vec2(0.5 * aspect, 0.5);  // 中心も調整
    float dist = distance(uv, center);

    float startTime = 2.0;
    float currentTime = uTime;
    float elapsedTime = currentTime - startTime;
    float lifeTime = 3.0;

    if (elapsedTime < 0.0 || elapsedTime > lifeTime) {
        gl_FragColor = vec4(0.0, 0.2, 0.4, 1.0);
        return;
    }

    float waveRadius = elapsedTime * 0.3;
    float waveThickness = 0.05;
    
    float distanceFromWave = abs(dist - waveRadius);
    float waveIntensity = 1.0 - (distanceFromWave / waveThickness);
    waveIntensity = max(0.0, waveIntensity);
    
    float wave = sin(dist * 25.0 - elapsedTime * 4.0);
    float positiveWave = max(0.0, wave);
    
    float distanceAttenuation = 1.0 / (1.0 + dist * 2.0);
    float timeAttenuation = exp(-elapsedTime * 0.5);
    
    float ripple = positiveWave * waveIntensity * distanceAttenuation * timeAttenuation;

    vec3 backgroundColor = vec3(0.0, 0.2, 0.4);
    vec3 finalColor = backgroundColor + vec3(1.0, 1.0, 1.0) * ripple * 2.0;

    gl_FragColor = vec4(finalColor, 1.0);
}