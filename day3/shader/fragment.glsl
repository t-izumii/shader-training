uniform float uTime;
uniform vec2 uMouse;
uniform vec2 uResolution;
varying vec2 vUv;

void main() {
    // アスペクト比を考慮したUV座標を計算
    vec2 uv = vUv;
    vec2 aspect = vec2(uResolution.x / uResolution.y, 1.0);
    uv = (uv - 0.5) * aspect + 0.5;
    
    // マウス座標もアスペクト比を考慮して変換
    vec2 mousePos = (uMouse + 1.0) * 0.5;
    mousePos = (mousePos - 0.5) * aspect + 0.5;
    
    // マウスからの距離を計算（アスペクト比を考慮）
    float dist = length(uv - mousePos);
    
    // 距離が0.1より小さい部分だけ色を表示
    float strength = 1.0 - smoothstep(0.0, 0.1, dist);
    
    // マウスの位置に基づいて色を生成
    vec3 color = vec3(
        1.0,  // マウスのx座標に応じた赤
        1.0,  // マウスのy座標に応じた緑
        1.0                       // 青は固定
    );

    // opacityを距離に基づいて調整
    color *= strength;
    
    gl_FragColor = vec4(color, 1.0);
}
