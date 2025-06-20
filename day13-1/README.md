# Day 13: 波紋（リップル）エフェクト

## 概要
このサンプルでは、インタラクティブな波紋エフェクトを実装しています。マウスクリックで波紋を生成し、リアルタイムでパラメータを調整できます。

## 機能

### インタラクティブ機能
- **マウスクリック**: クリックした位置に波紋を生成
- **マウスカーソル**: カーソル周辺に微細な光る効果
- **リアルタイムパラメータ調整**: 右側のコントロールパネルで各種パラメータを調整

### 波紋エフェクトの特徴
1. **物理的な波の表現**: 実際の水の波に近い伝播と減衰
2. **複数波紋の同時表示**: 最大5つの波紋を同時に表示
3. **自然な減衰**: 距離と時間による自然な減衰効果
4. **歪み効果**: 波紋による背景の歪み表現

### 調整可能なパラメータ
- **波の速度**: 波紋の伝播速度
- **波の密度**: 波の細かさ（周波数）
- **波の強さ**: 振幅の大きさ
- **減衰率**: 距離による減衰の強さ
- **歪み強度**: 背景歪みの強さ

## 実装のポイント

### 1. 波の方程式
```glsl
wave = sin(distance * frequency - time * speed)
```

### 2. 減衰効果
- **距離減衰**: `1.0 / (1.0 + distance * damping)`
- **時間減衰**: `exp(-time * 0.5)`
- **波面減衰**: `smoothstep` による波面の範囲制御

### 3. 歪み計算
勾配を計算して背景テクスチャを歪ませる：
```glsl
gradient = vec2(dRipple/dx, dRipple/dy)
distortedUV = uv + gradient * distortionStrength
```

### 4. 複数波紋の管理
- JavaScript側で波紋データを管理
- ユニフォーム配列でGLSLに送信
- 古い波紋の自動削除

## 学習のポイント

1. **物理シミュレーション**: 実際の波の性質を理解する
2. **配列ユニフォーム**: 複数のデータをシェーダーに送る方法
3. **インタラクション**: マウスイベントとシェーダーの連携
4. **最適化**: パフォーマンスを考慮したループ処理

## 応用可能性

- 水面のシミュレーション
- インタラクティブなUI要素
- ゲームでの魔法エフェクト
- 音声ビジュアライザー
- リアクティブなWebサイト背景

## 次のステップ

1. **音響連動**: 音声入力に応じた波紋生成
2. **物理改良**: より正確な波の干渉計算
3. **3D化**: 高さマップを使用した3D波紋
4. **テクスチャ追加**: より豊かな背景テクスチャ