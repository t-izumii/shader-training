#ifdef GL_ES
precision mediump float;
#endif

uniform float uTime;
uniform vec2 uResolution;
varying vec2 vUv;
varying float vElevation;

float random (in vec2 st) {
    return fract(sin(dot(st.xy,
                         vec2(12.9898,78.233)))*
        43758.5453123);
}

// Based on Morgan McGuire @morgan3d
// https://www.shadertoy.com/view/4dS3Wd
float noise (in vec2 st) {
    vec2 i = floor(st);
    vec2 f = fract(st);

    // Four corners in 2D of a tile
    float a = random(i);
    float b = random(i + vec2(1.0, 0.0));
    float c = random(i + vec2(0.0, 1.0));
    float d = random(i + vec2(1.0, 1.0));

    vec2 u = f * f * (3.0 - 2.0 * f);

    return mix(a, b, u.x) +
            (c - a)* u.y * (1.0 - u.x) +
            (d - b) * u.x * u.y;
}

#define OCTAVES 6
float fbm (in vec2 st) {
    // Initial values
    float value = 0.0;
    float amplitude = .5;
    float frequency = 0.;
    //
    // Loop of octaves
    for (int i = 0; i < OCTAVES; i++) {
        value += amplitude * noise(st);
        st *= 2.;
        amplitude *= .5;
    }
    return value;
}

void main() {
    vec3 color = vec3(0.0);

    // 高さに基づいて色を設定
    float height = vElevation;
    
    // 各地形の高さ閾値を調整
    float snowLine = 0.8;    // 雪線を高く
    float rockLine = 0.5;    // 岩肌の範囲を広げる
    float treeLine = 0.3;    // 森林限界を上げる
    
    // 地形の色定義
    vec3 snowColor = vec3(1.0, 1.0, 1.0);          // より純白に
    vec3 rockColor = vec3(0.4, 0.4, 0.45);         // より暗い灰色
    vec3 forestColor = vec3(0.15, 0.3, 0.15);      // より暗い深緑
    vec3 grassColor = vec3(0.25, 0.5, 0.25);       // より暗い草色
    
    // 高さに応じた色の補間
    if (height > snowLine) {
        color = snowColor;
    } else if (height > rockLine) {
        float t = (height - rockLine) / (snowLine - rockLine);
        t = smoothstep(0.0, 1.0, t);  // よりスムーズな遷移
        color = mix(rockColor, snowColor, t);
    } else if (height > treeLine) {
        float t = (height - treeLine) / (rockLine - treeLine);
        t = smoothstep(0.0, 1.0, t);
        color = mix(forestColor, rockColor, t);
    } else {
        float t = height / treeLine;
        t = smoothstep(0.0, 1.0, t);
        color = mix(grassColor, forestColor, t);
    }

    // 影の効果を強調
    float shadow = smoothstep(0.2, 0.8, height);
    color *= 0.3 + 0.7 * shadow;  // コントラストを強める

    gl_FragColor = vec4(color, 1.0);
}
