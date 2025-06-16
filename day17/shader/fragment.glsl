#ifdef GL_ES
precision mediump float;
#endif

// ユニフォーム変数
uniform float uTime;
uniform vec2 uResolution;
uniform vec2 uMouse;
uniform float uZoom;
uniform float uRotation;
uniform float uShapeSize;
uniform float uBlendAmount;
uniform float uAnimSpeed;
uniform int uOperationMode;
uniform float uHue;
uniform float uSaturation;
uniform float uColorAnimation;

varying vec2 vUv;

// 定数
#define PI 3.14159265359
#define TAU 6.28318530718

// =============================================================================
// SDF 基本形状関数
// =============================================================================

// 円のSDF
float sdCircle(vec2 p, float r) {
    return length(p) - r;
}

// 四角形のSDF
float sdBox(vec2 p, vec2 b) {
    vec2 d = abs(p) - b;
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
}

// 六角形のSDF
float sdHexagon(vec2 p, float r) {
    const vec3 k = vec3(-0.866025404, 0.5, 0.577350269);
    p = abs(p);
    p -= 2.0 * min(dot(k.xy, p), 0.0) * k.xy;
    p -= vec2(clamp(p.x, -k.z * r, k.z * r), r);
    return length(p) * sign(p.y);
}

// 三角形のSDF
float sdTriangle(vec2 p, float r) {
    const float k = sqrt(3.0);
    p.x = abs(p.x) - r;
    p.y = p.y + r / k;
    if (p.x + k * p.y > 0.0) p = vec2(p.x - k * p.y, -k * p.x - p.y) / 2.0;
    p.x -= clamp(p.x, -2.0 * r, 0.0);
    return -length(p) * sign(p.y);
}

// 星形のSDF
float sdStar(vec2 p, float r, int n, float m) {
    // n: 頂点数, m: 内側の比率
    float an = PI / float(n);
    float en = PI / m;
    vec2 acs = vec2(cos(an), sin(an));
    vec2 ecs = vec2(cos(en), sin(en));
    
    float bn = mod(atan(p.y, p.x), 2.0 * an) - an;
    p = length(p) * vec2(cos(bn), abs(sin(bn)));
    p -= r * acs;
    p += ecs * clamp(-dot(p, ecs), 0.0, r * acs.y / ecs.y);
    return length(p) * sign(p.x);
}

// =============================================================================
// SDF ブーリアン演算
// =============================================================================

// 合成（Union）
float opUnion(float d1, float d2) {
    return min(d1, d2);
}

// 減算（Subtraction）
float opSubtraction(float d1, float d2) {
    return max(-d1, d2);
}

// 交差（Intersection）
float opIntersection(float d1, float d2) {
    return max(d1, d2);
}

// スムーズ合成
float opSmoothUnion(float d1, float d2, float k) {
    float h = clamp(0.5 + 0.5 * (d2 - d1) / k, 0.0, 1.0);
    return mix(d2, d1, h) - k * h * (1.0 - h);
}

// スムーズ減算
float opSmoothSubtraction(float d1, float d2, float k) {
    float h = clamp(0.5 - 0.5 * (d2 + d1) / k, 0.0, 1.0);
    return mix(d2, -d1, h) + k * h * (1.0 - h);
}

// スムーズ交差
float opSmoothIntersection(float d1, float d2, float k) {
    float h = clamp(0.5 - 0.5 * (d2 - d1) / k, 0.0, 1.0);
    return mix(d2, d1, h) + k * h * (1.0 - h);
}

// =============================================================================
// 変換関数
// =============================================================================

// 2D回転行列
mat2 rotate2D(float angle) {
    float c = cos(angle);
    float s = sin(angle);
    return mat2(c, -s, s, c);
}

// 座標変換
vec2 transformCoord(vec2 uv) {
    // アスペクト比補正
    float aspect = uResolution.x / uResolution.y;
    uv.x *= aspect;
    
    // 中央を原点に
    uv -= vec2(aspect * 0.5, 0.5);
    
    // マウス位置によるパン
    uv += (uMouse - 0.5) * 0.5;
    
    // ズーム
    uv /= uZoom;
    
    // 回転
    uv = rotate2D(radians(uRotation)) * uv;
    
    return uv;
}

// HSVからRGBへの変換
vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

// =============================================================================
// メインのSDF関数
// =============================================================================

float getScene(vec2 p) {
    float time = uTime * uAnimSpeed;
    
    // アニメーション用のオフセット
    vec2 offset1 = vec2(cos(time * 0.7), sin(time * 0.5)) * 0.3;
    vec2 offset2 = vec2(cos(time * 1.1 + PI), sin(time * 0.8 + PI)) * 0.2;
    vec2 offset3 = vec2(cos(time * 0.9 + PI * 0.5), sin(time * 1.2 + PI * 0.5)) * 0.25;
    
    // 基本形状を作成
    float circle1 = sdCircle(p + offset1, uShapeSize);
    float box1 = sdBox(p + offset2, vec2(uShapeSize * 0.8));
    float hex1 = sdHexagon(p + offset3, uShapeSize * 0.9);
    
    // 追加の小さな形状
    float circle2 = sdCircle(p - offset1 * 1.5, uShapeSize * 0.6);
    float triangle1 = sdTriangle(p - offset2 * 1.2, uShapeSize * 0.7);
    
    // 演算モードに応じて合成
    float result;
    
    if (uOperationMode == 0) {
        // 合成モード
        result = opSmoothUnion(circle1, box1, uBlendAmount);
        result = opSmoothUnion(result, hex1, uBlendAmount);
        result = opSmoothUnion(result, circle2, uBlendAmount * 0.5);
        result = opSmoothUnion(result, triangle1, uBlendAmount * 0.5);
    } else if (uOperationMode == 1) {
        // 減算モード
        result = opSmoothSubtraction(circle1, box1, uBlendAmount);
        result = opSmoothSubtraction(hex1, result, uBlendAmount);
        result = opSmoothUnion(result, circle2, uBlendAmount * 0.3);
    } else {
        // 交差モード
        result = opSmoothIntersection(circle1, box1, uBlendAmount);
        result = opSmoothUnion(result, hex1, uBlendAmount);
        result = opSmoothIntersection(result, circle2, uBlendAmount * 0.8);
    }
    
    return result;
}

// =============================================================================
// レンダリング関数
// =============================================================================

vec3 render(vec2 uv) {
    vec2 p = transformCoord(uv);
    
    // SDF値を取得
    float d = getScene(p);
    
    // 距離に基づく色計算
    float edge = smoothstep(0.0, 0.02, abs(d));
    float fill = smoothstep(0.0, 0.005, -d);
    
    // 色相計算（時間とSDF値に基づく）
    float hue = uHue;
    if (uColorAnimation > 0.5) {
        hue += uTime * 30.0 + d * 100.0;
    }
    hue = mod(hue, 360.0) / 360.0;
    
    // 基本色
    vec3 fillColor = hsv2rgb(vec3(hue, uSaturation, 0.9));
    vec3 edgeColor = hsv2rgb(vec3(hue + 0.1, uSaturation * 0.8, 1.0));
    vec3 bgColor = hsv2rgb(vec3(hue + 0.5, uSaturation * 0.3, 0.1));
    
    // グラデーション効果
    float gradient = smoothstep(-0.5, 0.5, d);
    vec3 gradientColor = mix(fillColor, edgeColor, gradient);
    
    // 最終色の計算
    vec3 color = bgColor;
    color = mix(gradientColor, color, edge);
    color = mix(color, fillColor * 1.2, fill);
    
    // 外郭線の追加
    float outline = smoothstep(0.01, 0.015, abs(d + 0.01));
    color = mix(vec3(1.0), color, outline);
    
    return color;
}

// =============================================================================
// メイン関数
// =============================================================================

void main() {
    vec2 uv = vUv;
    uv.x *= uResolution.x / uResolution.y;
    
    float circle = sdCircle(uv, 0.5);

    // アンチエイリアシング（マルチサンプリング）
    vec3 color = vec3(1.0, 0.0, 0.0);
    float edge = smoothstep(0.0, 0.01, abs(circle));
    color = mix(color, vec3(0.0, 1.0, 0.0), edge);

    
    // 最終出力
    gl_FragColor = vec4(color, 1.0);
}