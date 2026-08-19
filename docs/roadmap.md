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
- [ ] Layout Engineのinterface設計（描画PoC前）
- [ ] ログ方針の実装（abstraction）

## Phase 1：Storage PoC

実機で、選んだフォルダにMarkdownを作成・読み・編集・保存できることを確認します。Obsidian Vaultを優先します。

- [ ] Android folder picker PoC
- [ ] Android Markdown read
- [ ] Android Markdown write
- [ ] iOS folder picker PoC
- [ ] iOS Markdown read
- [ ] iOS Markdown write
- [ ] Storage abstractionへPoC結果を反映する

## Phase 2：Markdown Core

UIより先に安定させます。

- [ ] Markdown Parser
- [ ] Markdown Serializer
- [ ] Tree操作（Add / Delete / Move / Reorder）
- [ ] Cycle防止
- [ ] Parse → Serialize → Parse のユニットテスト

## Phase 3：Mind Map Rendering PoC

- [ ] Horizontal Layout Engine
- [ ] Node描画（Widget）
- [ ] Edge描画（CustomPainter）
- [ ] Pan
- [ ] Zoom
- [ ] 100 Node程度での確認

## Phase 4：Editing

- [ ] Node選択
- [ ] Add Child / Sibling
- [ ] Edit（キャンバスから離れない）
- [ ] Delete
- [ ] Reorder / Move Parent（Drag）
- [ ] Collapse / Expand
- [ ] Undo / Redo

## Phase 5：Persistence

- [ ] Load / Save
- [ ] Autosave（debounce / atomic write）
- [ ] 外部変更の検知（上書き防止）
- [ ] File list
- [ ] Recent maps

## Phase 6：UX

- [ ] Animation
- [ ] Context Menu
- [ ] Keyboard / Focus
- [ ] Gesture競合の解消
- [ ] Fit to Screen

## Phase 7：Design

- [ ] MindMapTheme（Minimal / Soft / Dark）
- [ ] Dark Mode
- [ ] Typography
- [ ] Node Styleの差し替え口
- [ ] Home / Library UI

## Phase 8：Beta

- [ ] Android実機
- [ ] iPhone実機
- [ ] 大量Node Test
- [ ] File corruption test
- [ ] Obsidian interoperability test
