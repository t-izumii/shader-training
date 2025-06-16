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


void main() {
    vec2 uv = vUv;
    uv.x *= uResolution.x / uResolution.y;

    vec2 center = vec2(0.5 * uResolution.x / uResolution.y, 0.5);
    float dist = distance(uv, center);

    float wavePosition = uTime * 0.3;
    float waveThickness = 0.05;
    
    // 波面の強度
    float distanceFromWave = abs(dist - wavePosition);
    float waveIntensity = 1.0 - (distanceFromWave / waveThickness);
    waveIntensity = max(0.0, waveIntensity);
    
    // 正の値だけの波模様
    float wave = sin(dist * 25.0 - uTime * 4.0);
    float positiveWave = wave * 0.5 + 0.5;
    
    float ripple = positiveWave * waveIntensity;

    vec3 backgroundColor = vec3(0.0, 0.2, 0.4);
    vec3 finalColor = backgroundColor + vec3(1.0, 1.0, 1.0) * ripple * 2.0;

    gl_FragColor = vec4(finalColor, 1.0);
}