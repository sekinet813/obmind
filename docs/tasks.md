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

Status: BLOCKED
Reason: Xcodeが未インストールで、iOSシミュレータも実機も使えない。Command Line Toolsのみ。`flutter doctor`がXcode incompleteを報告する。

完了条件:

- security-scoped resourceをInfrastructureが扱う
- 実機またはシミュレータで確認できる。環境が無い場合はBLOCKEDにする

依存:

- T-006

### T-013iOS Markdown read / write

- [ ] 選んだディレクトリのMarkdownを読み、編集して保存する

Status: Skip
Reason: T-012がBLOCKEDのため実行できない

完了条件:

- 作成 → 読み込み → 編集 → 保存がiOSで確認できる
- Obsidian Vaultでの確認手順がdocsにある

依存:

- T-012

### T-014Storage abstractionへPoC結果を反映する

- [ ] PoCで分かった制約を`MindMapStorage`とarchitectureへ反映する

Status: Skip
Reason: T-013が未完了のため、iOS側の制約をarchitectureへ反映できない

完了条件:

- iOS / Android差がDomainに漏れていない
- 権限失効時のエラーが表現できる

依存:

- T-011
- T-013

## P1: Phase 2 Markdown Core

UIより先にParser / Serializer / Tree操作を安定させる。

### T-015 Markdown Parser

- [x] Markdownから`MindMapDocument`を構築する
- [x] ID欠落時に採番し、未対応ブロックを警告する

完了条件:

- Format v0.1のH1 + nested unordered listを`MindMapDocument`へ変換できる
- IDが無い既存MarkdownにIDを採番する
- 未対応ブロックを黙って捨てない（警告または失敗）
- DomainがFlutter WidgetとOS APIに依存しない

依存:

- T-005

Roadmap: Phase 2 Markdown Parser

### T-016 Markdown Serializer

- [x] `MindMapDocument`をFormat v0.1のMarkdownへ書き出す

完了条件:

- Frontmatter、H1、2スペースインデントの`- `リスト、HTMLコメントIDをこの順で出す
- collapsedと未知属性をコメントへ戻せる

依存:

- T-015

Roadmap: Phase 2 Markdown Serializer

### T-017 Tree操作

- [x] Add / Delete / Move / ReorderをDomainで行う

完了条件:

- Rootは削除できない
- childrenの順序が保持される
- 操作後もidが一意

依存:

- T-005

Roadmap: Phase 2 Tree操作

### T-018 Cycle防止

- [x] Nodeを自分の子孫へMoveできないようにする

完了条件:

- CycleになるMoveは拒否する
- ユニットテストがある

依存:

- T-017

Roadmap: Phase 2 Cycle防止

### T-019 Parse → Serialize → Parse

- [x] Round-tripで意味が維持されることをテストする

完了条件:

- Tree構造、text、ID、順序、collapsed、theme / layout / versionが維持される

依存:

- T-016

Roadmap: Phase 2 Parse → Serialize → Parse のユニットテスト

## P1: Phase 3 Mind Map Rendering PoC

### T-020 Horizontal Layout Engine

- [x] `MindMapDocument`から水平レイアウトの`MindMapLayout`を計算する

完了条件:

- 同一Inputに対して安定した`NodeLayout`になる
- DomainのNodeを変更しない
- 折りたたまれた子孫をレイアウトから省ける

依存:

- T-008

Roadmap: Phase 3 Horizontal Layout Engine

### T-021 Node描画

- [x] NodeをFlutter Widgetとして描画する

完了条件:

- Node textが表示される
- 座標をDomainモデルへ持たせない

依存:

- T-020

Roadmap: Phase 3 Node描画（Widget）

### T-022 Edge描画

- [x] 親子のEdgeをCustomPainterで描画する

完了条件:

- Layoutにある親子だけを描く
- Domainへ座標を保存しない

依存:

- T-020
- T-021

Roadmap: Phase 3 Edge描画（CustomPainter）

### T-023 Pan

- [x] Viewportで1本指Panできる

完了条件:

- NodeとEdgeがLayout座標で配置される
- PanがInteractiveViewerで有効

依存:

- T-021
- T-022

Roadmap: Phase 3 Pan

### T-024 Zoom

- [x] ViewportでPinch Zoomできる

完了条件:

- scaleEnabledが有効
- min / max scaleがある

依存:

- T-023

Roadmap: Phase 3 Zoom

### T-025 100 Node確認

- [x] 100 Node程度でLayoutとViewportが破綻しないことを確認する

完了条件:

- 同一InputのLayoutが安定する
- Viewportが100 Nodeを表示できる

依存:

- T-020
- T-023

Roadmap: Phase 3 100 Node程度での確認

### T-026 Node選択

- [x] キャンバス上のNodeを選択できる

完了条件:

- TapでNodeを選択できる
- 選択状態をMarkdownへ保存しない

依存:

- T-021

Roadmap: Phase 4 Node選択

### T-027 Add Child / Sibling

- [x] 選択中のNodeへChild / Siblingを追加する

完了条件:

- Domainの`MindMapTree`を通す
- RootのSiblingは追加できない

依存:

- T-017
- T-026

Roadmap: Phase 4 Add Child / Sibling

### T-028 Delete

- [x] 選択中の非Root Nodeを削除する

完了条件:

- Rootは削除できない
- Domainの`MindMapTree.delete`を通す

依存:

- T-017
- T-026

Roadmap: Phase 4 Delete

### T-029 Collapse / Expand

- [x] 選択中のNodeを折りたたみ・展開する

完了条件:

- collapsedがLayoutから子孫を外す
- MarkdownへはNodeコメント属性として残る（Serializer既存）

依存:

- T-020
- T-026

Roadmap: Phase 4 Collapse / Expand

### T-030 Edit（キャンバスから離れない）

- [ ] キャンバス上でNode textを編集する

Status: BLOCKED
Reason: インライン編集はキーボード・フォーカス・Pan/Zoomとの競合があり、Phase 6のGesture競合と一体で決める。Dialogへ逃げる実装は「キャンバスから離れない」要件を満たさない。

完了条件:

- 選択中のNode textをキャンバス上で編集できる
- 編集のために別画面やDialogへ遷移しない
- DomainのNode text更新を通す
- 選択状態をMarkdownへ保存しない

依存:

- T-026

Roadmap: Phase 4 Edit（キャンバスから離れない）

### T-031 Reorder / Move Parent（Drag）

- [ ] Dragで並び替えと親変更をする

Status: BLOCKED
Reason: 1本指PanとNode Dragの競合解消はPhase 6。DomainのMove / ReorderはT-017で完了済み。

完了条件:

- Dragで同一親内のReorderができる
- Dragで親を変更できる
- CycleになるMoveは拒否する
- 座標をDomainへ保存しない

依存:

- T-017
- T-018
- T-026

Roadmap: Phase 4 Reorder / Move Parent（Drag）

### T-032 Undo / Redo

- [ ] Add / Delete / Edit / Move / Reorder / Collapse をUndoできる

Status: BLOCKED
Reason: EditとDragが未完了のため対象操作が揃わない。部分的な履歴は誤解を招く。

完了条件:

- Add / Delete / Edit / Move / Reorder / Collapse / ExpandをUndoできる
- Redoができる
- 履歴をMarkdownやDomainモデルへ永続化しない

依存:

- T-027
- T-028
- T-029
- T-030
- T-031

Roadmap: Phase 4 Undo / Redo

## P1: Phase 5 Persistence

マインドマップの正本はMarkdownのまま、Load / SaveをApplicationでオーケストレーションする。無条件上書きしない。

### T-033 Load / Save

- [x] `MindMapDocument`をMarkdownから読み、編集結果を保存する

完了条件:

- ApplicationのLoad / SaveがParser / Serializerと`MindMapStorage`を使う
- マインドマップ画面のTreeがファイルと往復できる
- PresentationがファイルI/OやOS APIを直接呼ばない
- 保存失敗で既存Markdownを空にしない

依存:

- T-011
- T-016
- T-021

Roadmap: Phase 5 Load / Save

### T-034 Autosave（debounce / atomic write）

- [x] 編集をdebounceし、atomic writeで自動保存する

完了条件:

- 入力のたびに即Disk Writeしない
- 書き込み中の中断でも元ファイルが空や中途半端な内容になりにくい
- Domainがdebounceや一時ファイル名を知らない

依存:

- T-033

Roadmap: Phase 5 Autosave（debounce / atomic write）

### T-035 外部変更の検知（上書き防止）

- [x] 保存前に外部変更を検知し、無条件上書きしない

完了条件:

- 読み込み時のmtime / hashはInfrastructureが持つ
- DomainのNodeに外部変更検知用フィールドを載せない
- 外部変更時は上書きせず、失敗またはユーザーへの通知で止める
- 高度なConflict Resolutionは実装しない

依存:

- T-034

Roadmap: Phase 5 外部変更の検知（上書き防止）

### T-036 File list

- [x] 選んだフォルダのMarkdown一覧から地図を開ける

完了条件:

- `MindMapStorage.list`をApplication経由で使う
- 一覧から既存Markdownをマインドマップとして開ける
- PresentationがSAF / Document Pickerを直接呼ばない

依存:

- T-006
- T-033

Roadmap: Phase 5 File list

### T-037 Recent maps

- [x] 最近開いた地図を再開できる

完了条件:

- 最近開いたlocationをInfrastructureのPreferences等へ保存する
- パスやContent URIをDomainモデルへ載せない
- Markdown正本にRecentを書かない
- 権限失効時にアプリが落ちない

依存:

- T-033

Roadmap: Phase 5 Recent maps

## P1: Phase 6 UX

スマートフォンでの描画体験を優先する。常時表示UIは最小限にする。

### T-038 Animation

- [ ] Layout変化をアニメーションする

完了条件:

- Add / Delete / Collapse / ExpandでNodeとEdgeの移動がアニメーションする
- 座標をDomainへ保存しない
- Pan / Zoom操作そのものをアニメーション対象にしない

依存:

- T-027
- T-028
- T-029

Roadmap: Phase 6 Animation

### T-039 Context Menu

- [ ] 選択時のみContext Actionを出す

完了条件:

- 選択中のNodeに対してChild / Sibling追加、削除、折りたたみがContext Actionからできる
- 常時表示の編集UIを増やしすぎない
- 選択状態をMarkdownへ保存しない

依存:

- T-026
- T-027
- T-028
- T-029

Roadmap: Phase 6 Context Menu

### T-040 Keyboard / Focus

- [ ] キーボードとフォーカスの扱いを定義する

完了条件:

- Node選択とテキスト入力のフォーカス移動が定義されている
- ソフトウェアキーボード表示中もViewportが操作不能にならない
- Semantic Labelがある

依存:

- T-026

Roadmap: Phase 6 Keyboard / Focus

### T-041 Gesture競合の解消

- [ ] Pan / Zoom / Tap / Drag / 編集開始が衝突しないようにする

完了条件:

- 1本指Pan、Pinch Zoom、Node Tap、Long Press、Node Dragの役割が衝突しない
- インライン編集開始がPan / Zoomを壊さない入口がある
- 完了後、理由が解消していればT-030とT-031のBLOCKEDを外す

依存:

- T-023
- T-024
- T-026

Roadmap: Phase 6 Gesture競合の解消

### T-042 Fit to Screen

- [ ] 表示中の地図全体をViewportに収める

完了条件:

- Layout全体が画面内に収まる操作がある
- Domainへ座標を保存しない

依存:

- T-023
- T-024

Roadmap: Phase 6 Fit to Screen

## P1: Phase 7 Design

Themeは差し替え可能にする。課金実装はしない。

### T-043 MindMapTheme（Minimal / Soft / Dark）

- [ ] Minimal / Soft / Darkをキャンバスへ反映する

完了条件:

- `MindMapThemeId`に応じて3テーマが視覚的に区別できる
- テーマ識別子はDomainに置き、色や形状の実体はPresentation側にある
- 課金実装はしない

依存:

- T-021

Roadmap: Phase 7 MindMapTheme（Minimal / Soft / Dark）

### T-044 Dark Mode

- [ ] アプリ全体のDark Modeを入れる

完了条件:

- Material 3のダークカラーが使える
- マインドマップのContrastが落ちない
- DomainがFlutter Themeに依存しない

依存:

- T-043

Roadmap: Phase 7 Dark Mode

### T-045 Typography

- [ ] Node textのタイポグラフィを整える

完了条件:

- フォントサイズと行間がThemeから来る
- Dynamic Typeを可能な範囲で考慮する
- 日本語表示が欠けたり切れたりしない

依存:

- T-021

Roadmap: Phase 7 Typography

### T-046 Node Styleの差し替え口

- [ ] Nodeの見た目をWidget直書きから差し替え可能にする

完了条件:

- 色・角丸・余白が差し替え可能なStyleから来る
- Domainに描画Styleを置かない
- 新しいテーマ追加時にNode Widgetを複製しなくてよい

依存:

- T-043

Roadmap: Phase 7 Node Styleの差し替え口

### T-047 Home / Library UI

- [ ] 一覧・新規・最近の入口があるLibrary画面にする

完了条件:

- `features/library`としてホームがPoCボタンだけのプレースホルダではない
- 新規作成、一覧、最近開いた地図からマインドマップを開ける
- PresentationがOSファイルAPIを直接呼ばない

依存:

- T-036
- T-037

Roadmap: Phase 7 Home / Library UI

## P1: Phase 8 Beta

実装の完了確認。実機が無い項目はBLOCKEDにし、テストで完結できる項目は先に進める。

### T-048 Android実機

- [ ] Android実機でMVPの基本操作を確認する

完了条件:

- 実機でフォルダ選択、読み書き、マインドマップ表示、基本編集ができる
- 確認手順は`docs/mobile-testing.md`に沿う
- 実機が無い場合はBLOCKEDにする

依存:

- T-011
- T-033
- T-047

Roadmap: Phase 8 Android実機

### T-049 iPhone実機

- [ ] iPhone実機でMVPの基本操作を確認する

Status: Skip
Reason: T-012がBLOCKEDのため実行できない

完了条件:

- 実機またはシミュレータでフォルダ選択、読み書き、マインドマップ表示、基本編集ができる
- 確認手順は`docs/mobile-testing.md`に沿う
- 環境が無い場合はBLOCKEDにする

依存:

- T-012
- T-013
- T-033

Roadmap: Phase 8 iPhone実機

### T-050 大量Node Test

- [ ] 200 Node程度で描画と操作が破綻しないことを確認する

完了条件:

- 200 Node程度でLayoutが安定する
- Viewportが破綻しないことをテストまたは計測手順で残す
- T-025の100 Node確認を壊さない

依存:

- T-025
- T-033

Roadmap: Phase 8 大量Node Test

### T-051 File corruption test

- [ ] 保存失敗や不正ファイルでデータを失わないことをテストする

完了条件:

- 保存失敗・書き込み中断・不正Markdownで既存ファイルを空にしないテストがある
- Parse失敗が黙ったデータ消失にならない
- 高度な修復UIは実装しない

依存:

- T-034
- T-035

Roadmap: Phase 8 File corruption test

### T-052 Obsidian interoperability test

- [ ] Obsidian Vault想定のMarkdownと相互運用できることを確認する

完了条件:

- Format v0.1のVault想定MarkdownをParse / Serializeするテストがある
- Obsidianで開いても壊れない確認手順がdocsにある
- Obsidian専用APIに依存しない

依存:

- T-019
- T-033

Roadmap: Phase 8 Obsidian interoperability test



