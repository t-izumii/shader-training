uniform float uTime;
uniform vec2 uResolution;
varying vec2 vUv;

void main() {
    // UV座標を取得（0.0～1.0の範囲）
    vec2 uv = vUv;
    
    // 市松模様のサイズ（8x8の格子）
    float gridSize = 8.0;
    
    // UV座標を格子に分割
    vec2 grid = floor(uv * gridSize);
    
    // 市松模様の判定：座標の合計が偶数か奇数か
    float checker = mod(grid.x + grid.y, 2.0);
    
    // 色を設定（0.0 = 黒、1.0 = 白）
    vec3 color = vec3(checker);
    
    gl_FragColor = vec4(color, 1.0);
}
