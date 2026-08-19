# アーキテクチャ

## 方針

FlutterアプリはPresentation / Domain / Data / Infrastructureに分けます。

AndroidとiOSの両方を最初のターゲットとし、プラットフォーム固有処理はInfrastructureに閉じます。DomainはFlutter WidgetとOS APIへ依存しません。

```text
Flutter Application
│
├── Presentation
│   └── HomePage
│
├── Domain
│   ├── models/
│   ├── repositories/
│   └── services/
│
├── Data
│   └── repositories/
│
└── Infrastructure
    └── プラットフォーム固有実装
```

## レイヤーの責務

### Presentation

Flutter UI、ユーザー操作、画面状態を扱います。

- Widgetから直接ファイルI/OやOS APIを呼び出さない
- ドメインルールをWidgetに埋め込まない

### Domain

アプリの中核となるモデル、Repository interface、判定ルールを置きます。

- FlutterのWidgetに依存しない
- `dart:io`やAndroid / iOSの型に依存しない
- 他レイヤーへ依存しない

### Data

DomainのRepository interfaceを実装します。

- 永続化形式のparse / serializeを担当する
- ファイルパス、Content URI、iOSのファイルハンドルなどは扱わない
- 必要な入出力はInfrastructureの抽象経由で行う

### Infrastructure

Preferences、ファイルアクセス、共有メニュー、通知などOS依存の実装を置きます。

- Android / iOSの差分をこの層の外へ出さない
- PresentationやDomainがプラットフォーム分岐しなくて済むinterfaceを公開する

## 依存方向

```text
Presentation → Domain
Data → Domain
Infrastructure → Domainの抽象（必要な場合）
Presentation ↛ Dataの具象へ直接依存しない
Presentation ↛ Infrastructureの具象へ直接依存しない
Domain ↛ 他レイヤー
```

コピー後は、このファイルに保存先・状態遷移・画面構成などのアプリ固有の決定を追記してください。
