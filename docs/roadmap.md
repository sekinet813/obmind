# Obmind Roadmap

フェーズ俯瞰です。実行時の完了条件つきタスクは[tasks.md](tasks.md)を正本にします。タスク完了時は、対応する項目があればこのファイルも更新します。

まだ実装していない項目を完了扱いにしません。

## Phase 0：設計

- [x] Flutterプロジェクトが存在する（テンプレート由来）
- [x] Requirementsを整理する
- [x] Architecture document
- [x] Markdown Format v0.1
- [x] ADRを追加する
- [x] Domain Modelの骨格
- [x] Storage abstraction（interface）
- [x] Layout Engineのinterface設計（描画PoC前）
- [x] ログ方針の実装（abstraction）

## Phase 1：Storage PoC

実機で、選んだフォルダにMarkdownを作成・読み・編集・保存できることを確認します。Obsidian Vaultを優先します。

- [x] Android folder picker PoC
- [x] Android Markdown read
- [x] Android Markdown write
- [ ] iOS folder picker PoC
  - Status: BLOCKED Reason: Xcode未インストール。詳細は`docs/tasks.md`のT-012
- [ ] iOS Markdown read
  - Status: Skip Reason: T-012依存
- [ ] iOS Markdown write
  - Status: Skip Reason: T-012依存
- [ ] Storage abstractionへPoC結果を反映する
  - Status: Skip Reason: T-013未完了

## Phase 2：Markdown Core

UIより先に安定させます。

- [x] Markdown Parser
- [x] Markdown Serializer
- [x] Tree操作（Add / Delete / Move / Reorder）
- [x] Cycle防止
- [x] Parse → Serialize → Parse のユニットテスト

## Phase 3：Mind Map Rendering PoC

- [x] Horizontal Layout Engine
- [x] Node描画（Widget）
- [x] Edge描画（CustomPainter）
- [x] Pan
- [x] Zoom
- [x] 100 Node程度での確認

## Phase 4：Editing

- [x] Node選択
- [x] Add Child / Sibling
- [x] Edit（キャンバスから離れない）
- [x] Delete
- [x] Reorder / Move Parent（Drag）
- [x] Collapse / Expand
- [x] Undo / Redo

## Phase 5：Persistence

- [x] Load / Save
  - Task: T-033
- [x] Autosave（debounce / atomic write）
  - Task: T-034
- [x] 外部変更の検知（上書き防止）
  - Task: T-035
- [x] File list
  - Task: T-036
- [x] Recent maps
  - Task: T-037

## Phase 6：UX

- [x] Animation
  - Task: T-038
- [x] Context Menu
  - Task: T-039
- [x] Keyboard / Focus
  - Task: T-040
- [x] Gesture競合の解消
  - Task: T-041
- [x] Fit to Screen
  - Task: T-042

## Phase 7：Design

- [x] MindMapTheme（Minimal / Soft / Dark）
  - Task: T-043
- [x] Dark Mode
  - Task: T-044
- [x] Typography
  - Task: T-045
- [x] Node Styleの差し替え口
  - Task: T-046
- [x] Home / Library UI
  - Task: T-047

## Phase 8：Beta

- [ ] Android実機
  - Task: T-048
  - Status: BLOCKED Reason: エージェント環境から実機へアクセス不可
- [ ] iPhone実機
  - Task: T-049
  - Status: Skip Reason: T-012依存
- [x] 大量Node Test
  - Task: T-050
- [x] File corruption test
  - Task: T-051
- [x] Obsidian interoperability test
  - Task: T-052

## Phase 9：UX改善（ユーザーフィードバック）

日常利用の使い勝手を優先する。詳細な完了条件は[tasks.md](tasks.md)のT-053以降を参照。

- [x] Edit mode終了（バグ修正）
  - Task: T-053
- [x] ズーム操作の改善
  - Task: T-054
- [ ] ノード上の折りたたみ / 展開ボタン
  - Task: T-055
- [ ] マインドマップファイル名の変更
  - Task: T-056
- [ ] マインドマップの削除
  - Task: T-057
- [ ] Library一覧のCRUD強化
  - Task: T-058
- [ ] Vaultフォルダの永続化と設定画面
  - Task: T-059
- [ ] Radial Layout Engine
  - Task: T-060
- [ ] 初回オンボーディング
  - Task: T-061
- [ ] Library一覧の検索とソート
  - Task: T-062
- [ ] マインドマップ画面のAppBar整理
  - Task: T-063

## Phase 10：Brand & Visual Identity

アプリアイコン（紙質・パステル・レイヤー感）を正本に、ThemeとUI Surface、マインドマップキャンバスの見た目を統一する。詳細な完了条件は[tasks.md](tasks.md)のT-064以降を参照。

- [x] App Icon
  - Task: T-064
- [x] Brand Color Palette & App Theme
  - Task: T-065
- [x] Paper-morphism Surface Styling
  - Task: T-066
- [x] Mind Map Canvas Brand Alignment
  - Task: T-067
