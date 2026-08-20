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
- [ ] Edit（キャンバスから離れない）
  - Status: BLOCKED Reason: インライン編集とPan/Zoomの競合はPhase 6と一体。詳細はT-030
- [x] Delete
- [ ] Reorder / Move Parent（Drag）
  - Status: BLOCKED Reason: PanとDragの競合はPhase 6。Domain操作はT-017済み
- [x] Collapse / Expand
- [ ] Undo / Redo
  - Status: BLOCKED Reason: Edit / Drag未完了。詳細はT-032

## Phase 5：Persistence

- [x] Load / Save
  - Task: T-033
- [x] Autosave（debounce / atomic write）
  - Task: T-034
- [ ] 外部変更の検知（上書き防止）
  - Task: T-035
- [ ] File list
  - Task: T-036
- [ ] Recent maps
  - Task: T-037

## Phase 6：UX

- [ ] Animation
  - Task: T-038
- [ ] Context Menu
  - Task: T-039
- [ ] Keyboard / Focus
  - Task: T-040
- [ ] Gesture競合の解消
  - Task: T-041
- [ ] Fit to Screen
  - Task: T-042

## Phase 7：Design

- [ ] MindMapTheme（Minimal / Soft / Dark）
  - Task: T-043
- [ ] Dark Mode
  - Task: T-044
- [ ] Typography
  - Task: T-045
- [ ] Node Styleの差し替え口
  - Task: T-046
- [ ] Home / Library UI
  - Task: T-047

## Phase 8：Beta

- [ ] Android実機
  - Task: T-048
- [ ] iPhone実機
  - Task: T-049
  - Status: Skip Reason: T-012依存
- [ ] 大量Node Test
  - Task: T-050
- [ ] File corruption test
  - Task: T-051
- [ ] Obsidian interoperability test
  - Task: T-052
