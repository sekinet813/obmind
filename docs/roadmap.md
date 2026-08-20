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
