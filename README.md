# Flutter App Template

Android / iOS向けFlutterアプリをすぐに開発するためのテンプレートです。

GitHubの**Use this template**からコピーし、アプリ名・識別子・docsを埋めたあと、実装を始められます。`main`へmergeするとGitHub Actionsがテストし、Android Debug APKをArtifactとしてダウンロードできます。

## 使い方

1. このリポジトリの**Use this template**から新しいリポジトリを作る
2. `docs/tasks.md`の`T-001`から順に着手する
3. 以降の機能は`docs/tasks.md`へタスクを足して実装する

コピー直後の識別子（変更前提）:

| 項目 | 初期値 |
| --- | --- |
| package | `app_template` |
| Android applicationId | `com.example.app_template` |
| iOS Bundle ID | `com.example.appTemplate` |
| 表示名 | `App Template` |

識別子の変更箇所は`docs/tasks.md`の`T-001`を参照してください。

## 開発ドキュメント

エージェントで開発する場合は、まず[AGENTS.md](AGENTS.md)を読んでください。

- [開発タスク](docs/tasks.md)
- [アーキテクチャ](docs/architecture.md)
- [モバイルでの動作確認](docs/mobile-testing.md)
- [長時間・夜間自律開発](docs/overnight-development.md)

このテンプレートは長時間・夜間の自律開発にも使えます。`docs/tasks.md`と`AGENTS.md`、Codex Goal modeなどを組み合わせ、未完了タスクを順に実装・検証・コミットできます。開始時は[prompts/overnight.md](prompts/overnight.md)を使ってください。詳細は[docs/overnight-development.md](docs/overnight-development.md)を参照してください。

## ローカル開発

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

## CI

PRと`main`へのpush、手動実行で次が走ります。

- `flutter analyze`
- `flutter test`
- Debug APKのビルドとArtifactアップロード（Linux）
- iOSの署名なしビルド確認（macOS）

Artifact名は`<リポジトリ名>-debug-apk`です。ダウンロード手順は[docs/mobile-testing.md](docs/mobile-testing.md)を参照してください。

Flutter SDKバージョンは`.github/flutter-version`にピン固定しています。

## バージョン更新

テンプレートと、コピー後の各リポジトリの両方で次が動きます。

- Dependabot: pub依存とGitHub Actionsを週次でPRにする
- Flutter SDKピン: 週次でlatest stableを確認し、新しければPRにする

自動mergeはしません。CIが通ったPRを確認してからmergeしてください。Flutter SDKピン更新のPRは既定の`GITHUB_TOKEN`ではActionsが自動起動しないことがあります。その場合は対象ブランチでFlutter CIを手動実行してください。
