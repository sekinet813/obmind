# 開発タスク

このファイルは、今後の実装作業で参照する実行用バックログです。

コピー直後は起動用チェックリストだけがあります。アプリ固有の機能タスクは`T-004`以降として追加してください。

長時間・夜間の自律開発では、このファイルを未完了タスクの正本とします。手順は`docs/overnight-development.md`、開始用プロンプトは`prompts/overnight.md`を参照してください。

## 運用ルール

- ユーザーから明示的なタスク指定がある場合は、その指示を最優先する。
- 明示指定がない場合は、`P0` → `P1`の順で、依存関係を満たした未完了タスクを上から1つ選ぶ。
- 1度に扱うのは1タスクとする。通常作業では1タスク完了で終了し、長時間実行では次の実行可能タスクへ進む。
- 1タスクは、実装・テスト・静的解析・コミットまでを完結できるサイズにする。目安は30分から2時間で、数時間単位の巨大タスクは分割する。
- タスクには可能な限り目的、実装内容、完了条件、必要なテスト、依存タスクを書く。完了条件は必須とする。
- タスク完了時は、このファイルのチェックボックスを更新する。
- 検証が成功し、完了条件を満たした場合のみ`[x]`にする。BLOCKEDや依存待ちは`[x]`にしない。
- 進められないタスクは未完了のまま、`Status: BLOCKED`と`Reason`を追記する。
- あるタスクがBLOCKEDでも、依存しない別タスクがあれば長時間実行全体は止めない。
- 仕様変更が必要になった場合は、実装だけを先行させず`docs/architecture.md`も更新する。
- 追加依存は最小限にし、追加理由をPR説明またはコミットメッセージに残す。
- タスク完了前に`dart format --set-exit-if-changed .`、`flutter pub get`、`flutter analyze`、`flutter test`を実行し、失敗したコードを残したまま次へ進まない。
- `T-001`から`T-003`はアプリ名・識別子・概要など人間の入力が必要である。長時間実行の主対象は、これらを埋めたあとの機能タスクとする。

## タスクの書き方

チェックボックスは次を意味します。

- `[ ]` 未着手または未完了
- `[x]` 完了

進められない場合の例:

```markdown
### T-010ホーム画面の実装

- [ ] ホーム画面にアプリ名と説明を表示する

Status: BLOCKED
Reason: 表示文言の確定が必要
```

機能タスクを追加するときの記述例です。実タスクとしては追加しないでください。

```markdown
### T-010ホーム画面の実装

- [ ] ホーム画面にアプリ名と説明を表示する

目的:
- 起動直後に、アプリの目的が分かる画面を出す

実装内容:
- `HomePage`にタイトルと短い説明を表示する

完了条件:
- ホーム画面にタイトルと説明が表示される
- `flutter analyze`と`flutter test`が成功する

必要なテスト:
- ホーム画面のWidget Test

依存:
- なし

### T-011データモデルの追加

- [ ] ドメインモデルを追加する

完了条件:
- 不変IDを持つモデルがある
- モデルのユニットテストがある

依存:
- なし

### T-012Repositoryの実装

- [ ] DomainのRepository interfaceとDataの実装を追加する

完了条件:
- PresentationがRepositoryの具象へ直接依存していない
- Repositoryのユニットテストがある

依存:
- T-011
```

## P0: コピー直後の初期化

### T-001アプリ識別子の変更

- [ ] アプリ名・package名・Android applicationId・iOS Bundle IDを変更する

変更対象の例:

- `pubspec.yaml`の`name` / `description`
- `lib/`と`test/`の`package:app_template/...` import
- Android `applicationId`と`namespace`（`android/app/build.gradle.kts`）
- Android Kotlinパッケージ（`android/app/src/main/kotlin/`）
- Android表示名（`android/app/src/main/AndroidManifest.xml`の`android:label`）
- iOS `PRODUCT_BUNDLE_IDENTIFIER`（`ios/Runner.xcodeproj/project.pbxproj`）
- iOS表示名（`ios/Runner/Info.plist`の`CFBundleDisplayName` / `CFBundleName`）
- `lib/l10n/app_ja.arb`の`appTitle`

完了条件:

- 旧識別子`app_template` / `com.example.app_template` / `com.example.appTemplate`が残っていない
- `flutter analyze`と`flutter test`が成功する

### T-002プロジェクト概要の更新

- [ ] `AGENTS.md`のプロジェクト概要を、コピーしたアプリの目的に合わせて書く

完了条件:

- テンプレートであることの説明ではなく、作るアプリの説明になっている
- エージェントが最初に読む順がこのアプリのdocs構成と一致している

### T-003アーキテクチャの更新

- [ ] `docs/architecture.md`をアプリ仕様に合わせて更新する

完了条件:

- Presentation / Domain / Data / Infrastructureの責務がアプリの機能と対応している
- プラットフォーム固有処理の置き場所が書かれている

### T-004最初の機能タスクを追加する

- [ ] このファイルへ、最初に実装する機能タスクを追加する

完了条件:

- 優先度、要件、完了条件がある
- エージェントが次に着手するタスクを1つ選べる

## P1: アプリ機能

T-004で追加したタスクから着手する。
