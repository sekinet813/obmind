# アーキテクチャ

ObmindはUI、Domain、Markdown、File Systemを分離します。厳密なClean Architectureそのものが目的ではありません。

## 方針

- FlutterでiOSとAndroidを対象にする。片方だけ壊す変更をしない
- DomainはFlutter WidgetとOS APIへ依存しない
- UI座標をDomainへ保存しない
- ファイルアクセスは抽象化し、SAF / Document Picker / iCloud / ObsidianをInfrastructureへ閉じる
- Feature-firstを基本にする。巨大な`models/` `services/` `screens/`だけの構成にはしない
- 追加依存は最小限にする

## ディレクトリ

```text
lib/
├── app/
│   ├── app.dart
│   └── router.dart          # 将来
├── core/
│   ├── errors/
│   ├── logging/
│   ├── theme/
│   └── utils/
├── features/
│   ├── mind_map/
│   │   ├── domain/
│   │   ├── application/
│   │   ├── infrastructure/
│   │   └── presentation/
│   ├── library/
│   │   ├── domain/
│   │   ├── application/
│   │   └── presentation/
│   └── settings/            # 将来
└── main.dart
```

テンプレート当時の`lib/data`は各featureの`infrastructure`へ吸収します。OS固有型はInfrastructureの外へ出しません。

## レイヤー

```text
Presentation
│
├── Screens
├── MindMapViewport
├── NodeWidget
└── Toolbar
     ↓
Application
│
├── LayoutEngine（MindMapDocument → MindMapLayout）
├── CreateNode / EditNode / DeleteNode
├── MoveNode / ReorderNode
├── LoadMindMap / SaveMindMap
└── Undo / Redo
     ↓
Domain
│
├── MindMapDocument / MindNode / NodeId
├── MindMapThemeId / LayoutType
└── MindMapStorage（interface）
     ↓
Infrastructure
├── MarkdownParser / MarkdownSerializer
├── FileMindMapRepository
├── AndroidDocumentStorage
└── IOSDocumentStorage
```

### Presentation

Flutter UI、画面状態、ジェスチャ、アニメーションを扱います。Widgetから直接ファイルI/OやOS APIを呼びません。ドメインルールをWidgetに埋め込みません。

マインドマップ描画の基本形:

```text
MindMapViewport
├── EdgeLayer（CustomPainter）
└── NodeLayer（MindNodeWidget...）
```

Layout EngineはWidgetから独立させ、`MindMapDocument`から`NodeLayout`を計算します。全Nodeを常時Widget Treeへ載せ続けないよう、将来のViewport Cullingを阻害しない構造にします。契約はApplication層の`LayoutEngine`です。

### Application

ノード操作、Load/Save、Undo/Redoなどのユースケースを置きます。UIの一時的なStateとDomain Stateを混ぜません。

Layout Engineもここに置きます。Presentationが測った`NodeSize`を入力し、表示用の`MindMapLayout`を返します。`NodeLayout`の`x` / `y`は計算結果であり、DomainモデルやMarkdownへ保存しません。

```dart
abstract interface class LayoutEngine {
  MindMapLayout layout(
    MindMapDocument document, {
    required Map<NodeId, NodeSize> nodeSizes,
  });
}
```

### Domain

モデルとルールとRepository interfaceだけを置きます。

- FlutterのWidgetに依存しない
- `dart:io`やAndroid / iOSの型に依存しない
- Nodeに`x` / `y`を持たせない

内部構造の詳細は[ADR-0004](decisions/ADR-0004-domain-model.md)です。

### Infrastructure

Markdownのparse / serialize、ファイルアクセス、Preferences、プラットフォーム固有処理を置きます。PresentationやDomainがOS分岐しなくて済むinterfaceを公開します。

## 依存方向

```text
Presentation → Application → Domain
Infrastructure → Domain
Presentation ↛ Infrastructureの具象
Domain ↛ 他レイヤー
```

## 状態管理

Riverpodを第一候補とします。ただし導入時点でFlutter / Dartとの互換性を確認します。Phase 0では未導入です。理由は[ADR-0001](decisions/ADR-0001-architecture.md)です。

## Storage抽象

Domain / Applicationは次のような抽象だけに依存します。シグネチャは実装しながら調整して構いません。

```dart
abstract interface class MindMapStorage {
  Future<String> read(MindMapLocation location);
  Future<void> write(MindMapLocation location, String markdown);
  Future<List<MindMapFile>> list(MindMapLocation folder);
}
```

`MindMapLocation`はパス文字列やContent URIをDomainへ漏らさないための値です。実体のURIやsecurity-scoped bookmarkはInfrastructureが持ちます。

Autosaveはdebounceとatomic writeを前提にします。保存直前に外部変更を検知できるよう、読み込み時のファイル情報（更新時刻やハッシュ）をInfrastructure側で保持し、無条件上書きしません。高度なConflict ResolutionはMVP対象外です。

## Markdown

正本はMarkdownです。Parser / SerializerはInfrastructureに置き、round-tripで意味を維持します。形式は[markdown-format.md](markdown-format.md)です。

ローカルDBを使う場合も、キャッシュ・インデックス・UI状態・検索用に限定します。

## Logging

`print()`を無秩序に使いません。`lib/core/logging`の`AppLogger`を使い、`dart:developer`へ書き出します。Productionでは`configureAppLogging(suppressDebug: kReleaseMode)`でDebug Logを抑制します。Domainはこのabstractionをimportしません。

## Error Handling

次を想定します。ファイル不在、権限失効、Parse失敗、不正なTree、保存失敗、外部変更、Storage不足。保存処理ではData Loss防止を最優先します。

## Accessibility

十分なTap領域、Dynamic Type、Semantic Label、Dark Mode、Contrastを可能な範囲で考慮します。

## 収益化の置き場所

基本機能とMarkdown保存とデータアクセスを過度に課金対象にしません。Themeなどは後からFree / Proへ分けやすい識別子にしておきます。課金実装自体はMVP対象外です。
