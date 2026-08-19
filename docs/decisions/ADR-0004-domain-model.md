# Domain Model（ADR-0004）

- Status: Accepted
- Date: 2026-08-19

## 問題

マインドマップをメモリ上でどう持つか。Tree操作、Undo、検索、Markdownの入れ子、将来のLayoutを同時に考える必要がある。Nodeへ座標を持たせると、正本と表示が結合する。

## 選択肢

1. 入れ子の`MindNode.children`を正本にする
2. 扁平なNode配列と`parentId`を正本にする
3. Nodeに`x` / `y`を持たせ、自由配置も同じモデルで扱う

## 決定

選択肢1。座標は持たない。Layout Engineが`MindMapDocument`から`NodeLayout`を計算する。

```text
MindMapDocument
├── id（任意）
├── title（Rootのtextと同期）
├── root: MindNode
├── theme
├── layout
├── formatVersion
└── extraObmindFields

MindNode
├── id: NodeId
├── text
├── children
├── collapsed
└── metadata
```

Undo / 検索用のidインデックスはApplication層が都度構築してよい。永続化しない。

`MindMapStorage`はDomainのinterfaceとし、パスやContent URIはInfrastructureが`MindMapLocation`の裏に隠す。

外部変更検知用のmtime / hashはInfrastructureが持ち、DomainのNodeには載せない。

## 理由

- Markdownの入れ子と構造が一致する
- Parent最大1というMVPのTree制約が型として自然
- 表示座標を正本に混ぜない

## Trade-off

- 深い木のid検索は走査または派生インデックスが必要
- 扁平モデルの方が一部のMove実装は単純になり得るが、Serialize時に親子を復元する負担が増える
- Cycle防止やMove / Reorderの本実装はPhase 2へ送る。Phase 0は不変条件（id一意、Root 1つ、座標なし）まで

## collapsedの永続化

FrontmatterのIDリストではなく、Node行のHTMLコメント属性とする。Nodeが移動しても属性が一緒に動く。
