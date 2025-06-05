uniform float uTime;
uniform vec2 uResolution;
varying vec2 vUv;

vec2 randomGradient(int ix, int iy) {
    float random = 2920.0 * sin(dot(vec2(ix, iy), vec2(21942.0, 171324.0))) * cos(dot(vec2(ix, iy), vec2(23157.0, 217832.0)));
    return vec2(cos(random), sin(random));
}

// Perlinノイズ関数
float perlinNoise(vec2 st) {
    // 格子点の計算
    int x0 = int(floor(st.x));
    int x1 = x0 + 1;
    int y0 = int(floor(st.y));
    int y1 = y0 + 1;

    // 距離ベクトルの計算
    vec2 d00 = st - vec2(x0, y0);
    vec2 d10 = st - vec2(x1, y0);
    vec2 d01 = st - vec2(x0, y1);
    vec2 d11 = st - vec2(x1, y1);

    // 勾配ベクトルの取得
    vec2 g00 = randomGradient(x0, y0);
    vec2 g10 = randomGradient(x1, y0);
    vec2 g01 = randomGradient(x0, y1);
    vec2 g11 = randomGradient(x1, y1);

    // ドット積の計算
    float n00 = dot(g00, d00);
    float n10 = dot(g10, d10);
    float n01 = dot(g01, d01);
    float n11 = dot(g11, d11);

    // 補間
    vec2 fade = smoothstep(0.0, 1.0, d00);
    float nx0 = mix(n00, n10, fade.x);
    float nx1 = mix(n01, n11, fade.x);
    float nxy = mix(nx0, nx1, fade.y);

    return nxy;
}


void main() {
    vec2 uv = vUv;
    float aspect = uResolution.x / uResolution.y;
    uv.x *= aspect;

    uv.x += uTime * 1.0;
    uv.y += uTime * 1.0;

    float n = perlinNoise(uv);
    vec3 color = vec3(n * 0.5 + 0.5, n * 0.2 + 0.5, n);

    gl_FragColor = vec4(color, 1.0);
}
