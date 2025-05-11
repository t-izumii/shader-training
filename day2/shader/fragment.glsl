uniform float uTime;
uniform vec2 uMouse;
varying vec2 vUv;

void main() {
    vec2 uv = vUv;

    vec2 mousePos = uMouse;
    
    // マウスの位置をデバッグ用に表示
    vec3 color = vec3( abs(mousePos.x) * uv.x, abs(mousePos.y) * uv.y, sin(uTime) );
    
    gl_FragColor = vec4(color, 1.0);
}
