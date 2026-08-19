# 開発タスク

このファイルは実行用バックログです。フェーズ俯瞰は[roadmap.md](roadmap.md)です。タスク完了時は、対応するroadmap項目があれば両方を更新します。

長時間・夜間の自律開発では、このファイルを未完了タスクの正本とします。手順は[overnight-development.md](overnight-development.md)、開始用プロンプトは`prompts/overnight.md`を参照してください。

## 運用ルール

- ユーザーから明示的なタスク指定がある場合は、その指示を最優先する
- 明示指定がない場合は、`P0` → `P1`の順で、依存関係を満たした未完了タスクを上から1つ選ぶ
- 1度に扱うのは1タスクとする。通常作業では1タスク完了で終了し、長時間実行では次の実行可能タスクへ進む
- 1タスクは、実装・テスト・静的解析・コミットまでを完結できるサイズにする
- 完了条件を満たした場合のみ`[x]`にする。BLOCKEDや依存待ちは`[x]`にしない
- 進められないタスクは未完了のまま、`Status: BLOCKED`と`Reason`を追記する
- 仕様変更が必要になった場合は、実装だけを先行させず関連docsも更新する
- 追加依存は最小限にし、追加理由をPR説明またはコミットメッセージに残す
- タスク完了前に`dart format --set-exit-if-changed .`、`flutter pub get`、`flutter analyze`、`flutter test`を実行し、失敗したコードを残したまま次へ進まない
- Markdown互換性を壊さない。ユーザーデータを失う実装をしない。Scope外機能を勝手に追加しない
- 本番のApplication ID / Bundle IDは[ADR-0003](decisions/ADR-0003-identifiers.md)が未決のままである。勝手に確定しない

## P0: Phase 0 設計

### T-001開発用識別子への変更

- [x] Dart package名・表示名をObmindへ変更する
- [x] Android / iOSの開発用プレースホルダを`com.example.obmind`にする

完了条件:

- Dart packageは`obmind`
- 表示名は`Obmind`
- 本番IDは未決定のままADRにTODOがある

Roadmap: Phase 0

### T-002プロジェクト概要の更新

- [x] `AGENTS.md`と`README.md`をObmind向けに書き換える

完了条件:

- Product Principlesと読む順がこのアプリのdocs構成と一致している

Roadmap: Phase 0

### T-003アーキテクチャと要件ドキュメント

- [x] `docs/requirements.md` / `docs/architecture.md` / `docs/markdown-format.md` / `docs/testing.md` / ADRを追加する

完了条件:

- Feature-firstとStorage抽象、Markdown v0.1が文書化されている

Roadmap: Phase 0

### T-004実行タスクの整備

- [x] `docs/roadmap.md`とこのファイルを対応づける

完了条件:

- 次に着手するタスクを1つ選べる

Roadmap: Phase 0

### T-005Domain Modelの骨格

- [x] `MindMapDocument` / `MindNode` / `NodeId` / `LayoutType` / `MindMapThemeId`を追加する
- [x] id一意などのユニットテストを追加する

完了条件:

- DomainがFlutter WidgetとOS APIに依存しない
- UI座標フィールドがモデルに無い
- `flutter analyze`と`flutter test`が成功する

Roadmap: Phase 0 Domain Modelの骨格

### T-006Storage abstraction

- [x] `MindMapStorage` interfaceをDomainに追加する

完了条件:

- 具象のパス / Content URI / SAF型をinterfaceが公開していない
- テスト用のメモリ実装でread / write / listできる

Roadmap: Phase 0 Storage abstraction

### T-007本番Application ID / Bundle ID

- [ ] 本番のAndroid applicationIdとiOS Bundle IDを設定する

Status: BLOCKED
Reason: 本番識別子は人間が決める。開発用は`com.example.obmind`。[ADR-0003](decisions/ADR-0003-identifiers.md)

### T-008Layout Engineのinterface設計

- [x] Domain外の`NodeLayout`とLayout Engine interfaceを文書または骨格コードで定義する

目的:

- 描画PoCの前に、座標がDomainへ入らない境界を固定する

完了条件:

- `MindMapDocument`から`NodeLayout`を返す契約がある
- Nodeに`x` / `y`を足していない

依存:

- T-005

Roadmap: Phase 0 Layout Engineのinterface設計

### T-009ログ方針の実装

- [x] `print()`に頼らないlogging abstractionを`lib/core`へ追加する

完了条件:

- ProductionでDebug Logを抑制できる入口がある
- DomainがFlutter loggingに依存しない

Roadmap: Phase 0 ログ方針の実装

## P1: Phase 1 Storage PoC

Parserより先に、実機でフォルダへMarkdownを読み書きできるかを確認する。実装はInfrastructureに閉じる。

### T-010Android folder picker PoC

- [x] ユーザーがフォルダを選び、その場所へMarkdownを作成できる

完了条件:

- PresentationがSAF APIを直接呼ばない
- 実機またはエミュレータでフォルダ選択ができる。環境が無い場合はBLOCKEDにする

依存:

- T-006

### T-011Android Markdown read / write

- [x] 選んだフォルダのMarkdownを読み、編集して保存する

完了条件:

- 作成 → 読み込み → 編集 → 保存がAndroidで確認できる
- 保存失敗でファイルを空にしない

依存:

- T-010

### T-012iOS folder picker PoC

- [ ] ユーザーがディレクトリを選び、その場所へMarkdownを作成できる

完了条件:

- security-scoped resourceをInfrastructureが扱う
- 実機またはシミュレータで確認できる。環境が無い場合はBLOCKEDにする

依存:

- T-006

### T-013iOS Markdown read / write

- [ ] 選んだディレクトリのMarkdownを読み、編集して保存する

完了条件:

- 作成 → 読み込み → 編集 → 保存がiOSで確認できる
- Obsidian Vaultでの確認手順がdocsにある

依存:

- T-012

### T-014Storage abstractionへPoC結果を反映する

- [ ] PoCで分かった制約を`MindMapStorage`とarchitectureへ反映する

完了条件:

- iOS / Android差がDomainに漏れていない
- 権限失効時のエラーが表現できる

依存:

- T-011
- T-013
