# Day 17: 2D SDF アート

## 🎯 学習目標

### SDF（Signed Distance Function）とは
**距離関数**を使って形状を数学的に定義する手法です。
- **正の値**: 形状の外側
- **負の値**: 形状の内側  
- **ゼロ**: 形状の境界

## 🎨 実装されている機能

### 1. 基本SDF形状
- **円**: `sdCircle(p, radius)`
- **四角形**: `sdBox(p, size)`
- **六角形**: `sdHexagon(p, radius)`
- **三角形**: `sdTriangle(p, radius)`
- **星形**: `sdStar(p, radius, points, ratio)`

### 2. SDF演算子（ブーリアン演算）
- **合成（Union）**: 形状を結合
- **減算（Subtraction）**: 形状をくり抜き
- **交差（Intersection）**: 重なり部分のみ表示

### 3. スムーズブレンド
- **smoothstep()**: 境界を滑らかに
- **opSmoothUnion()**: 滑らかな合成
- **opSmoothSubtraction()**: 滑らかな減算
- **opSmoothIntersection()**: 滑らかな交差

### 4. カメラワーク機能
- **ズーム**: マウスホイールまたはスライダー
- **パン**: マウス移動
- **回転**: 手動/自動回転
- **アニメーション**: 形状の動的変化

## 🎮 操作方法

### 基本操作
1. **マウス移動**: カメラをパン（移動）
2. **右パネル**: パラメータをリアルタイム調整
3. **演算モードボタン**: 形状の合成方法を切り替え

### パラメータ説明
- **ズーム**: 表示倍率（0.5-5.0倍）
- **回転**: 全体の回転角度
- **形状サイズ**: 基本形状の大きさ
- **ブレンド**: 形状間の滑らかさ
- **アニメ速度**: 動的変化の速さ

## 📚 学習段階

### レベル1: SDF基礎理解
```glsl
// 円のSDF - 最もシンプル
float sdCircle(vec2 p, float r) {
    return length(p) - r;  // 中心からの距離 - 半径
}

// 使用例
float d = sdCircle(uv - vec2(0.5, 0.5), 0.3);
if (d < 0.0) {
    // 円の内側
    color = vec3(1.0, 0.0, 0.0);  // 赤
} else {
    // 円の外側
    color = vec3(0.0, 0.0, 1.0);  // 青
}
```

### レベル2: ブーリアン演算
```glsl
// 2つの円を合成
float circle1 = sdCircle(p - vec2(-0.2, 0.0), 0.3);
float circle2 = sdCircle(p - vec2(0.2, 0.0), 0.3);

// 合成（どちらかの形状）
float unionResult = min(circle1, circle2);

// 減算（circle2からcircle1をくり抜き）
float subtractResult = max(-circle1, circle2);

// 交差（両方の形状が重なる部分）
float intersectResult = max(circle1, circle2);
```

### レベル3: スムーズブレンド
```glsl
// 硬い境界の合成
float hardUnion = min(d1, d2);

// 滑らかな境界の合成
float opSmoothUnion(float d1, float d2, float k) {
    float h = clamp(0.5 + 0.5 * (d2 - d1) / k, 0.0, 1.0);
    return mix(d2, d1, h) - k * h * (1.0 - h);
}
```

## 🛠️ カスタマイズ例

### 新しい形状を追加
```glsl
// ハート形のSDF
float sdHeart(vec2 p) {
    p.x = abs(p.x);
    if (p.y + p.x > 1.0)
        return sqrt(dot(p - vec2(0.25, 0.75), p - vec2(0.25, 0.75))) - sqrt(2.0) / 4.0;
    return sqrt(min(dot(p - vec2(0.0, 1.0), p - vec2(0.0, 1.0)),
                    dot(p - 0.5 * max(p.x + p.y, 0.0), p - 0.5 * max(p.x + p.y, 0.0)))) * sign(p.x - p.y);
}
```

### カスタムアニメーション
```glsl
// 脈動する円
float time = uTime * 2.0;
float radius = 0.3 + sin(time) * 0.1;
float d = sdCircle(p, radius);
```

### カスタムカラーリング
```glsl
// 距離に基づくグラデーション
float d = getScene(p);
vec3 color1 = vec3(1.0, 0.0, 0.5);  // マゼンタ
vec3 color2 = vec3(0.0, 0.5, 1.0);  // シアン
float t = smoothstep(-0.1, 0.1, d);
vec3 finalColor = mix(color1, color2, t);
```

## 🎯 課題の進め方

### 基本課題: 複数形状の組み合わせ
1. **目標**: 3つ以上の基本形状を組み合わせて抽象アートを作成
2. **手順**:
   - 異なる形状を配置
   - ブーリアン演算で組み合わせ
   - アニメーションを追加

### 応用課題: スムーズブレンド
1. **目標**: smoothstep()とmix()で滑らかな境界を実現
2. **手順**:
   - 硬い境界と滑らかな境界を比較
   - ブレンド係数を調整
   - 色のグラデーション効果を追加

### 発展課題: 動的カメラワーク
1. **目標**: ズーム・パン・回転を組み合わせたアート表現
2. **手順**:
   - マウス連動のカメラ制御
   - 時間ベースの自動カメラワーク
   - 音楽に同期したアニメーション（応用）

## 💡 学習のポイント

### SDFの利点
1. **解像度独立**: ベクター的な鮮明さ
2. **数学的精密さ**: 正確な形状定義
3. **効率的な演算**: GPUに最適化
4. **柔軟性**: 複雑な形状も簡単に作成

### デバッグ手法
```glsl
// SDF値を可視化
float d = getScene(p);
vec3 debugColor = vec3(d > 0.0 ? d : 0.0, d < 0.0 ? -d : 0.0, 0.0);
```

### 最適化Tips
1. **計算の最小化**: 不要な形状は早期にリターン
2. **LOD**: 距離に応じた詳細度調整
3. **キャッシュ**: 重複計算の回避

## 🌟 発展アイデア

### アートスタイル
- **ミニマリスト**: シンプルな形状と色
- **オーガニック**: 自然な曲線と動き
- **幾何学的**: 精密な数学的パターン
- **サイケデリック**: 複雑な色変化とアニメーション

### インタラクティブ要素
- **音響連動**: 音楽に合わせた変化
- **リアルタイム描画**: マウスで形状を描く
- **物理シミュレーション**: 重力や衝突の表現

## 📖 参考リソース

### 公式ドキュメント
- [Inigo Quilez's SDF Functions](https://iquilezles.org/articles/distfunctions2d/)
- [Shadertoy SDF Examples](https://www.shadertoy.com/results?query=sdf)

### 学習サイト
- [SDF Tutorial Series](https://www.youtube.com/watch?v=62-pRVZuS5c)
- [Book of Shaders - Shapes](https://thebookofshaders.com/07/)

## 🚀 実行方法

1. `index.html` をブラウザで開く
2. 右パネルでパラメータを調整
3. マウスでカメラを操作
4. 演算モードを切り替えて効果を比較

## 🔧 改造のヒント

### 新しい形状を追加したい場合
1. `fragment.glsl` の SDF 基本形状関数セクションに追加
2. `getScene()` 関数内で形状を配置
3. ブーリアン演算で既存形状と組み合わせ

### アニメーションを変更したい場合
1. `getScene()` 関数内の `offset` 計算を変更
2. `time` ベースの変化パターンを調整
3. `uAnimSpeed` で速度制御

### 色彩を変更したい場合
1. `render()` 関数内の色計算を変更
2. `hsv2rgb()` を使用してHSV色空間で制御
3. `uHue`, `uSaturation` で動的変更

---

**次のステップ**: パラメータを変更して、あなただけのユニークなSDF Artを作成してみましょう！

#SDF #2DArt #GLSL #DistanceFunction #ProceduralArt