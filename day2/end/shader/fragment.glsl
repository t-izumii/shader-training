uniform float uTime;
uniform vec2 uResolution;
varying vec2 vUv;

void main() {
    // UV座標とアスペクト比補正
    vec2 uv = vUv;
    float aspect = uResolution.x / uResolution.y;
    uv.x *= aspect;
    
    // 中心座標
    vec2 center = vec2(0.5 * aspect, 0.5);
    
    // 中心からの距離を計算
    float dist = distance(uv, center);
    
    // 基本のSin波同心円
    float wave = sin(dist * 25.0 - uTime * 3.0);
    
    // -1～1の値を0～1に変換
    float pattern = (wave + 1.0) * 0.5;
    
    // 白黒のパターンを出力
    vec3 color = vec3(pattern);
    
    gl_FragColor = vec4(color, 1.0);
}