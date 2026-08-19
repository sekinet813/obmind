# AGENTS.md

## プロジェクト概要

Obmind（オブマインド）は、Markdownファイルを正本とするLocal-firstなマインドマップアプリです。iOS / Android向けにFlutterで開発します。

思考を囲い込むサービスではなく、思考を気持ちよく整理する道具です。データはユーザーのものです。Obmindがなくなっても、思考はMarkdownとして残ります。

## Product Principles

迷ったら次へ立ち返る。

- Markdown is Source of Truth。DBはキャッシュ・インデックス・UI状態・検索用に限定する
- Local-first。MVPに独自バックエンドを持たない
- ユーザーがデータを所有する。Obsidian専用にはしない
- 通常UIでMarkdown編集を要求しない
- スマートフォンでの描画体験を、機能数より優先する

## 最優先事項

```text
1. ユーザーデータを失わない
2. Markdown互換性
3. UI / UX
4. シンプルなArchitecture
5. Performance
6. 機能数
```

## Codexが最初に読むもの

作業開始時は、変更対象に関係なく次の順で確認する。

1. `AGENTS.md`
2. `docs/tasks.md`
3. `docs/roadmap.md`
4. `docs/architecture.md`
5. 必要に応じて`docs/requirements.md`、`docs/markdown-format.md`、`docs/testing.md`
6. 必要に応じて`docs/mobile-testing.md`
7. 長時間実行時は`docs/overnight-development.md`と`prompts/overnight.md`

ユーザーから明示的なタスク指定がある場合はその指示を最優先する。

明示的なタスク指定がない場合は、`docs/tasks.md`から依存関係を満たした最優先の未完了タスクを選ぶ。フェーズの位置づけは`docs/roadmap.md`で確認する。

## 実装前の確認

- 実装前に`docs/roadmap.md`と対象タスクの完了条件を確認する
- 一度に巨大な機能を実装しない。1度に実装するのは1タスクだけとする
- Scope外機能（独自クラウド、アカウント、Graph、自由配置、AI、Web / Desktopなど）を勝手に追加しない
- Markdown互換性を壊さない。Formatの破壊的変更はADRなしに行わない
- Domain層はFlutter WidgetとOS APIへ依存しない
- Storage実装を抽象化する。SAF / Document Picker / iCloud / ObsidianをDomain / Presentationから直接呼ばない
- UI座標をDomainへ保存しない
- Data Lossを最優先で防ぐ。保存失敗や外部変更を無条件上書きしない
- 実装後にテストを追加する。日付計算や状態遷移、Tree操作、Markdown変換にはユニットテストを付ける

## タスク実行ルール

- 同じタスクに必要な小さな修正はまとめてよい
- 通常作業では1タスクを完了したら終了する。長時間実行では完了後に次の実行可能タスクへ進む
- 先のフェーズを便利そうという理由だけで先行実装しない
- 完了条件を満たした場合のみ`docs/tasks.md`のチェックボックスを`[x]`に更新する。対応する`docs/roadmap.md`の項目があれば同様に更新する
- 一部だけ完了した場合はチェックを付けず、必要ならタスク配下へ残課題を追記する
- 実装中に仕様の矛盾や不足を見つけた場合、推測で大きく仕様変更せず、最小の安全な実装を選ぶ。重要な判断はPR説明またはADRに残す
- 仕様を変更した場合はコードだけでなく関連docsも同じPRで更新する
- リファクタリングはタスク達成に必要な範囲に留める
- タスクを完了とみなす前に、必ず次を実行して成功を確認する。失敗したコードを残したまま次のタスクへ進まない

```bash
dart format --set-exit-if-changed .
flutter pub get
flutter analyze
flutter test
```

コード生成が必要なアプリでは、既存手順に従ってから上記を実行する。

## 基本方針

- Flutter / Dartで実装する
- AndroidとiOSの両方をターゲットとする。片方のOSだけ壊す変更をしない
- 将来的なDesktop対応を壊さない設計にする
- UIから直接ファイルI/OやOS APIを呼び出さない
- プラットフォーム固有処理はInfrastructure層へ閉じ込める
- 日本語UIをデフォルトとする
- Material 3を基本とする
- 追加依存は最小限にする。新規パッケージを追加した場合はPR説明で利用目的を示す
- パッケージ追加前に、標準APIまたは既存依存で十分に実現できないか確認する
- 日本語と英字の間に半角スペースを入れない。英単語同士の半角スペースは残す
- IDには表示名ではなくUUID等の不変IDを使う
- 日付は内部ではタイムゾーンの曖昧さを避け、保存形式を統一する
- 破壊的なマイグレーションやデータ形式変更は、後方互換性を検討せず実施しない

## 勝手に固定しない判断

次はADRなしに確定しない。問題・選択肢・推奨・Trade-offを`docs/decisions/`へ残す。

- Markdown Formatの破壊的変更
- 独自Backend / Firebase / User Account / Cloud Storage
- 課金方式
- 本番のApplication ID / Bundle ID
- 自由配置方式への変更
- TreeからGraphへの変更

## 想定アーキテクチャ

```text
lib/
├── app/
├── core/
└── features/
    ├── mind_map/
    │   ├── domain/
    │   ├── application/
    │   ├── infrastructure/
    │   └── presentation/
    └── library/
```

主な責務:

- Presentation: Flutter UI、状態表示、ユーザー操作
- Application: ユースケース、Undo/Redo、Load/Saveのオーケストレーション
- Domain: モデル、Repository interface、ドメインルール
- Infrastructure: Markdown parse/serialize、ファイルアクセス、プラットフォーム固有処理

詳細は`docs/architecture.md`を参照する。

## 品質確認

コード変更後は、環境上実行可能な範囲で必ず次を実行する。

```bash
dart format --set-exit-if-changed .
flutter pub get
flutter analyze
flutter test
```

Android実装を変更した場合は、可能ならAndroidビルドも確認する。

```bash
flutter build apk --debug
```

iOS実装を変更した場合は、可能ならiOSビルドも確認する。

```bash
flutter build ios --debug --no-codesign
```

失敗した場合:

1. コード原因なら修正する
2. 修正後に再実行する
3. SDKや実行環境など環境依存で実行不能な場合のみ、その理由をPR説明に残す
4. 長時間実行では、後述の自己修復とBLOCKEDルールに従う

## 長時間実行

`prompts/overnight.md`を使う場合、またはユーザーが未完了タスクの継続処理を指示した場合に適用する。Codex Goal modeなどの長時間実行機能から使うことを想定するが、ルール自体はエージェント共通とする。

人間向け手順は`docs/overnight-development.md`を参照する。

### 適用とループ

```text
TASKS確認
↓
次の実行可能タスクを選択
↓
仕様確認
↓
実装
↓
format / pub get / analyze / test
↓
必要なら修正
↓
TASKS更新（必要ならroadmapも）
↓
commit
↓
次のタスク
```

1つのタスクが完了しても、実行可能な未完了タスクがある限り終了しない。

### タスク選択

1. `docs/tasks.md`から未完了タスクを探す
2. 依存関係が解決済みのタスクを優先する
3. 原則として上から順番に処理する
4. 1度に複数タスクを実装しない
5. 1タスクを完了してから次へ進む
6. `docs/roadmap.md`でフェーズを確認し、先のフェーズを勝手に実装しない

本番Application ID / Bundle IDなど人間の入力が必要なタスクは、値が未確定ならBLOCKEDにし、機能タスクがあればそちらを進める。

### 実装前の確認

タスク開始前に必ず次を確認する。

- `AGENTS.md`
- `docs/tasks.md`
- `docs/roadmap.md`
- `docs/architecture.md`
- コピー後に追加された関連docs
- 関連コードと既存テスト

不明点は、既存仕様・コード・テストから合理的に判断できる軽微な内容であれば自律的に判断する。判断できない場合は停止条件に従う。

### 自己修復

検証が失敗したら、すぐに諦めるのではなく次を繰り返す。

```text
エラー確認
↓
原因調査
↓
修正
↓
再実行
```

修正と再実行は最大3回とする。同じ原因で繰り返す場合、または3回以内に成功しない場合はBLOCKEDにする。無限ループは避ける。

### 1つのタスクで止まらない

あるタスクがBLOCKEDになっても、その問題と無関係な別タスクを実行できる場合は長時間実行全体を終了しない。

```text
Task 01 完了
Task 02 BLOCKED
Task 03 Task 02依存 → Skip
Task 04 独立 → 実行
Task 05 独立 → 実行
```

次のいずれかに整理され、実行可能なタスクがなくなった場合に終了する。

- 完了
- BLOCKED
- BLOCKEDタスクへの依存（Skip）

BLOCKED後に次へ進む前に、失敗した実装変更を破棄し、作業ツリーを検証成功状態へ戻す。`docs/tasks.md`のBLOCKED記録だけは残し、必要ならその記録だけをコミットする。失敗したコードを残したまま次のタスクへ進まない。

### 停止条件

次に当たる場合は自律判断で強行しない。そのタスクをBLOCKEDとして理由を記録し、独立した他タスクがあれば進める。

- 要件を大きく左右する仕様判断
- データ消失につながる操作
- 本番環境への変更
- 外部サービスへの課金
- APIキー・パスワード・秘密情報が必要
- DBの破壊的migration
- セキュリティ設計を大きく変更する判断
- git historyの破壊的変更
- force push
- 解決方法が複数あり、アーキテクチャに重大な影響を与える判断

### Git運用

長時間実行時は原則として1タスク = 1コミットとする。小さすぎる修正を不自然に分割する必要はない。コミット前に検証を成功させる。

```text
feat: add mind map domain model
feat: implement markdown parser
feat: implement horizontal layout engine
test: add markdown round-trip tests
docs: define markdown format v0.1
```

巨大なCommitを避ける。

次はユーザーから明示的な指示がある場合のみ行う。エージェントは勝手に実行しない。

- push
- merge
- force push
- main / masterへの直接的な破壊操作

### 終了レポート

長時間実行の終了時は、通常のPR説明に加えて次の形式で報告する。

```markdown
## Overnight Development Summary

### Completed
- T-005 ...
- T-006 ...

### Blocked
- T-007
  - Reason: ...

### Skipped
- T-008
  - Reason: T-007 dependency

### Validation
- dart format: PASS
- flutter analyze: PASS
- flutter test: PASS (xx tests)

### Commits
- abc123 feat: ...
- def456 feat: ...

### Human Review Required
- ...
```

## PR / 作業完了時の報告

PR説明または最終報告には最低限以下を含める。長時間実行では上記のOvernight Development Summaryも必ず付ける。

- 対応したタスクID（例: `T-001`）
- 実装内容
- 重要な設計判断
- 追加した依存と理由
- 実行したテスト / コマンドと結果
- 未完了事項や既知の制約
- `docs/tasks.md`（と必要なら`docs/roadmap.md`）を更新したか

## Code Review Rules

- DomainがFlutter WidgetやOS APIに依存している変更を指摘する
- プラットフォーム固有処理がPresentation / Domainへ漏れている変更を指摘する
- Androidだけ、またはiOSだけを壊す変更を指摘する
- 仕様変更なのにdocsが更新されていない変更を指摘する
- テストなしで状態遷移や計算ロジックを変更している場合は指摘する
- Markdown互換性やData Loss防止を損なう保存処理を指摘する
- UI座標をDomainモデルへ追加している変更を指摘する
