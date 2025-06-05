uniform float uTime;
uniform vec2 uResolution;
varying vec2 vUv;

vec3 rgb2hsv(vec3 c) {
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

// HSVからRGBへの変換関数
vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}


void main() {
    vec2 uv = vUv;
    float aspect = uResolution.x / uResolution.y;
    uv.x *= aspect;

    // 画面中央を原点とする
    vec2 center = vec2(0.5, 0.5);
    vec2 toCenter = uv - center;

        // 極座標への変換
    float radius = length(toCenter);
    float angle = atan(toCenter.y, toCenter.x);
    
    // 角度を0〜1の範囲に正規化（色相として使用）
    float hue = (angle / (2.0 * 3.14159));
    
    // HSVカラーの作成（彩度は外側ほど高く、明度は一定）
    vec3 hsv = vec3(hue, radius * 2.0, 1.0);
    
    // HSVからRGBに変換
    vec3 color = hsv2rgb(hsv);
    
    // 円の境界をつける
    if (radius > 0.5) {
        color = vec3(0.1);
    }

    gl_FragColor = vec4(color, 1.0);
}

