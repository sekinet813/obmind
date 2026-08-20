# Obmind

**Visual thinking. Your files.**

Obmind（オブマインド）は、Markdownファイルをデータの正本として扱う、Local-firstなマインドマップアプリです。

スマートフォンでグラフィカルにマインドマップを編集しつつ、データはサービス側ではなくユーザー自身が所有します。Obmindを使わなくなっても、思考はMarkdownとして残ります。

## 現状

いまはPhase 0です。設計ドキュメントとDomain Modelの骨格までがあり、マインドマップ編集UI・ファイル保存・Obsidian Vault連携はまだありません。起動すると日本語のプレースホルダホーム画面だけが表示されます。

## Local-first

基本的な作成・編集はインターネット接続なしで使えることを目標にします。MVPではObmind専用バックエンドを持ちません。

## Markdown

マインドマップの正本はMarkdownです。

- H1がRoot Node
- 入れ子の箇条書きがChild Node
- Node IDはHTMLコメントとして保存し、通常のMarkdown表示を邪魔しにくくします

独自情報を除いても、一般的なMarkdownとして意味が残る形式にします。詳細は[docs/markdown-format.md](docs/markdown-format.md)を参照してください。

## Obsidianとの関係

Obsidian APIへ接続するアプリではありません。ユーザーが選んだフォルダ（Obsidian Vaultを含む）のMarkdownを読み書きする想定です。Obsidian Sync、Git、Syncthingなど既存の同期手段をそのまま使えます。

## 対応Platform

MVPの対象はiOSとAndroidです。Web / macOS / Windowsは対象外です。

## Development

```bash
dart format --set-exit-if-changed .
flutter pub get
flutter analyze
flutter test
```

Android:

```bash
flutter build apk --debug
```

iOS:

```bash
flutter build ios --debug --no-codesign
flutter run
```

エージェントで開発する場合は、まず[AGENTS.md](AGENTS.md)を読んでください。

- [要件](docs/requirements.md)
- [アーキテクチャ](docs/architecture.md)
- [Markdown Format v0.1](docs/markdown-format.md)
- [ロードマップ](docs/roadmap.md)
- [開発タスク](docs/tasks.md)
- [テスト方針](docs/testing.md)
- [モバイルでの動作確認](docs/mobile-testing.md)
- [長時間・夜間自律開発](docs/overnight-development.md)

長時間実行の開始時は[prompts/overnight.md](prompts/overnight.md)を使ってください。

## Architecture

Feature-firstを基本とし、UI・Domain・Markdown・File Systemを分離します。Domain層はFlutter WidgetとOS APIへ依存しません。詳細は[docs/architecture.md](docs/architecture.md)です。

## Roadmap

Phase 0（設計）から始め、Storage PoC、Markdown Core、描画、編集、永続化、UX、Design、Betaの順で進めます。[docs/roadmap.md](docs/roadmap.md)がフェーズ俯瞰、[docs/tasks.md](docs/tasks.md)が実行用バックログです。

## 識別子

| 項目 | 現在の値 | 備考 |
| --- | --- | --- |
| package | `obmind` | Dart package名 |
| 表示名 | `Obmind` | |
| Android applicationId | `com.example.obmind` | 開発用。本番IDは未決定 |
| iOS Bundle ID | `com.example.obmind` | 開発用。本番IDは未決定 |

## CI

PRと`main`へのpush、手動実行で次が走ります。

- `dart format --set-exit-if-changed .`
- `flutter analyze`
- `flutter test`
- Debug APKのビルドとArtifactアップロード（`main`へのpush時のみ）

Flutter SDKバージョンは`.github/flutter-version`にピン固定しています。ローカルでも同じバージョンを使ってください。

```bash
# 例: SDKが /Volumes/ssd/development/flutter/sdk の場合
cd /path/to/flutter
git fetch --tags
git switch --detach "$(tr -d '[:space:]' < /path/to/obmind/.github/flutter-version)"
flutter --version
```
