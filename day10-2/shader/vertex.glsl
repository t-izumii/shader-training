varying vec2 vUv;
varying float vHeight;
uniform float uTime;

// 改良版randomGradient
vec2 randomGradient(int ix, int iy) {
    // より安定したハッシュ関数を使用
    float random = fract(sin(dot(vec2(ix, iy), vec2(12.9898, 78.233))) * 43758.5453);
    float angle = 6.283185 * random; // 2π * random
    return vec2(cos(angle), sin(angle));
}

// Perlinノイズ関数
float perlinNoise(vec2 st) {
    // 格子点の計算
    vec2 i = floor(st);
    vec2 f = fract(st);
    
    // 4つの角の勾配ベクトルを取得
    vec2 g00 = randomGradient(int(i.x), int(i.y));
    vec2 g10 = randomGradient(int(i.x+1.0), int(i.y));
    vec2 g01 = randomGradient(int(i.x), int(i.y+1.0));
    vec2 g11 = randomGradient(int(i.x+1.0), int(i.y+1.0));
    
    // 距離ベクトル
    vec2 d00 = f;
    vec2 d10 = f - vec2(1.0, 0.0);
    vec2 d01 = f - vec2(0.0, 1.0);
    vec2 d11 = f - vec2(1.0, 1.0);
    
    // ドット積
    float n00 = dot(g00, d00);
    float n10 = dot(g10, d10);
    float n01 = dot(g01, d01);
    float n11 = dot(g11, d11);
    
    // 補間
    vec2 u = smoothstep(0.0, 1.0, f);
    float nx0 = mix(n00, n10, u.x);
    float nx1 = mix(n01, n11, u.x);
    float nxy = mix(nx0, nx1, u.y);
    
    return nxy;
}

void main() {
    vUv = uv;

    float noiseScale = 100.0;
    float timeFactor = uTime * 0.1;
    float heightMultiplier = 100.0;

    vec3 pos = position;
    float n = perlinNoise(vUv * noiseScale + vec2(timeFactor, timeFactor * 0.7));
    vHeight = (n + 1.0) * 0.5;

    pos.z += n * 10.0 * uTime;
    gl_Position = projectionMatrix * modelViewMatrix * vec4(pos, 1.0);
}
