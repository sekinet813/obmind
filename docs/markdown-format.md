# Markdown Format v0.1

Obmindが生成・読み込むMarkdownの契約です。破壊的変更はADRなしに行いません。

## 原則

1. 正本はMarkdownファイルである
2. Obmind独自情報をすべて削除しても、一般的なMarkdownとして意味が残る
3. 通常のMarkdown表示（GitHub、Obsidianプレビューなど）を大きく邪魔しない
4. MVPで必要以上の独自metadataを増やさない

独自情報を除いた例:

```markdown
# Root

- Child A
  - Child A1
- Child B
```

## 基本構造

- YAML Frontmatterの`obmind`ブロック = 文書全体の表示情報
- H1 = Root Node
- nested unordered list = Child Node

```markdown
---
obmind:
  version: 1
  theme: minimal
  layout: horizontal
---

# 新サービス <!-- obmind:id=root -->

- 課題 <!-- obmind:id=problem -->
  - データロックイン <!-- obmind:id=lockin -->
  - 月額料金 <!-- obmind:id=price -->
- 解決策 <!-- obmind:id=solution -->
  - Markdown <!-- obmind:id=markdown -->
  - Local-first <!-- obmind:id=local-first -->
```

例の`root`や`problem`は説明用です。実装が採番するIDはUUID等の不変値です。人間がIDを編集することは想定しません。

## Frontmatter

MVPで書いてよいキーは次のみです。

```yaml
obmind:
  version: 1
  theme: minimal
  layout: horizontal
```

| キー | 意味 | MVPの値 |
| --- | --- | --- |
| `version` | Format版 | `1` |
| `theme` | テーマ識別子 | `minimal` / `soft` / `dark` / `inkwell` |
| `layout` | レイアウト | `horizontal` / `radial`（未指定時は `horizontal`） |

未知のキーは読み込み時に保持し、可能なら書き戻します。`layout`と`theme`の未知の値も警告したうえで保持し、表示はそれぞれ`horizontal` / `minimal`として扱います。将来の`nodeStyles`などはv0.1では書きません。

`version`のメジャーが未知のファイルは、黙って破壊せず警告または読み取り失敗として扱います。

## Node ID

各Nodeは永続IDを持ちます。保存形式はHTMLコメントです。

```html
<!-- obmind:id=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx -->
```

理由:

- 通常のMarkdown表示を邪魔しにくい
- Obsidianでも本文として目立ちにくい
- 並び替え後も同一Nodeを識別できる
- 将来のstyle等と関連付けできる

コメントは見出しまたはリスト項目の行末に置きます。

### 任意属性

折りたたみはNodeローカルの状態としてコメントへ保存します。Frontmatterへ散らしません。

```html
<!-- obmind:id=problem collapsed=true -->
```

`collapsed`が無い、または`false`のときは展開です。未知の属性は保持し、可能なら書き戻します。

## 読み込み

### Obmind生成ファイル

`obmind.version`があるファイルはFormat v0.1として解釈します。H1が1つ、その後にunordered listが続く形を想定します。

### 既存の単純Markdown

次のような入れ子リストはインポート対象です。欠けたIDは読み込み時に採番し、保存時に書き戻します。

```markdown
# Root

- A
  - A1
  - A2
- B
```

### 未対応のMarkdown

任意の複雑なMarkdownの完全な双方向変換はv0.1の必須ではありません。コードブロック、テーブル、複数H1、順序付きリスト、引用、Wiki Linkなどは未対応です。

方針:

- 未対応ブロックを黙って捨てて上書きしない
- Parserは警告を返す
- 保存してよいかはApplication層が判断する
- Compatibility ModeやRead-only previewは将来検討

実装はPhase 2です。

## 書き出し

Serializerは次をこの順で出します。

1. Frontmatter（`obmind`ブロック）
2. 空行
3. `# {root.text} <!-- obmind:id=... -->`
4. nested unordered list（2スペースインデント）

リストマーカーは`- `です。Rootのtextと文書タイトルは同一です。

## Round-trip

次が意味を維持することをテストで保証します（Phase 2）。

```text
Markdown → Parse → Serialize → Parse
```

保証する意味:

- Tree構造
- Node text
- Node ID
- childrenの順序
- collapsed
- theme / layout / version

空白やコメント位置の完全一致までは必須としませんが、Obmindが書いたファイルは安定して同じ構造に戻る必要があります。

## 正本に含めないもの

次はMarkdownへ書きません。

- Nodeの画面座標
- Pan / Zoom位置
- 選択状態
- Undo履歴
- 検索インデックス
