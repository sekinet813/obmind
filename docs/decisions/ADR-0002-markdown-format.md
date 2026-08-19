# Markdown Format v0.1（ADR-0002）

- Status: Accepted
- Date: 2026-08-19

## 問題

マインドマップの正本をMarkdownにするとき、Tree・Node ID・テーマ・折りたたみを、一般的なMarkdown互換を壊さずに保存する必要がある。

## 選択肢

1. 独自JSON / YAMLファイルを正本にする
2. Markdown本文に独自記法（Wiki風）を埋め込む
3. H1 + nested unordered listを本文とし、IDはHTMLコメント、文書情報はYAML Frontmatterにする

## 決定

選択肢3をFormat v0.1とする。契約は[markdown-format.md](../markdown-format.md)である。

- H1 = Root
- nested `- ` list = Child
- `<!-- obmind:id=... -->`でNode ID
- 折りたたみはコメント属性`collapsed=true`
- Frontmatterの`obmind`は`version` / `theme` / `layout`のみ

## 理由

- 独自情報を消しても普通のMarkdownとして読める
- Obsidianプレビューで本文を大きく汚さない
- 並び替え後も同一Nodeを識別できる

## Trade-off

- HTMLコメントを手で消すとIDが失われ、次回保存で新しいIDが付く
- 複雑なMarkdownの完全な双方向変換は保証しない
- コメント属性の文法はObmind独自であり、他ツールは無視する想定

## やってはいけないこと

Formatの破壊的変更（H1以外をRootにする、IDを必須の可視テキストにする、Graphを本文の正本にする等）は、このADRを置き換えるまで行わない。
