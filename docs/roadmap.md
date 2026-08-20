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
- [x] ノード上の折りたたみ / 展開ボタン
  - Task: T-055
- [x] マインドマップファイル名の変更
  - Task: T-056
- [x] マインドマップの削除
  - Task: T-057
- [x] Library一覧のCRUD強化
  - Task: T-058
- [x] Vaultフォルダの永続化と設定画面
  - Task: T-059
- [x] Radial Layout Engine
  - Task: T-060
- [x] 初回オンボーディング
  - Task: T-061
- [x] Library一覧の検索とソート
  - Task: T-062
- [x] マインドマップ画面のAppBar整理
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

## Phase 11：LayoutとViewportの使い勝手

Radialを日常利用の既定にし、開いたときにRootが中央へ来るようにする。自由配置やGraph化は対象外。詳細な完了条件は[tasks.md](tasks.md)のT-068以降を参照。

- [x] 新規地図の既定LayoutをRadialにする
  - Task: T-068
- [x] Root子ノードの周囲配置と子孫の一方向伸長
  - Task: T-069
- [x] 地図を開いたときにRootを中央表示する
  - Task: T-070
- [x] Radial LayoutのRoot原点を安定させる
  - Task: T-071
- [x] Radial Layout向けEdge接続
  - Task: T-072
- [x] Rootへ戻る操作とFit to Screenの役割分担
  - Task: T-073
- [x] ノード追加時に対象が見えるようViewportを保つ
  - Task: T-074

## Phase 12：Library・編集UX・テンプレート

一覧の探しやすさ、編集中のキーボード、文言、デザインプリセットを整える。詳細な完了条件は[tasks.md](tasks.md)のT-075以降を参照。

- [x] 新規地図の既定名を「新規マインドマップ」にする
  - Task: T-075
- [x] キーボード表示時に編集中ノードを見える位置へ移動する
  - Task: T-076
- [x] 「正本フォルダ」を「保存フォルダ」に言い換える
  - Task: T-077
- [x] マインドマップ編集画面から設定ボタンを外す
  - Task: T-078
- [x] デザインテンプレート（色と形のプリセット）
  - Task: T-079
- [x] 一覧検索をノード本文まで対象にする
  - Task: T-080
- [x] 一覧のリスト形式とプレビュー付きタイル形式
  - Task: T-081
- [x] 一覧タイトル左にアプリアイコンを置く
  - Task: T-082

## Phase 13：親ノード・文言・デザインテーマ

親ノードとファイル名を揃え、デザインはテーマ変更に限定する。水平・放射はデザインでは切り替えない。詳細な完了条件は[tasks.md](tasks.md)のT-083以降を参照。

- [x] 親ノードとファイル名を揃える
  - Task: T-083
- [x] マインドマップ編集画面の保存ボタンを削除する
  - Task: T-084
- [x] ユーザー向けメッセージから「正本」を外す
  - Task: T-085
- [x] デザイン変更でLayoutを変えない
  - Task: T-086
- [x] デザインテーマを4種に拡充する
  - Task: T-087

## Phase 14：Play Storeリリース準備

Google Play提出のための準備。本番Application IDはT-007（人間が決定）。詳細な完了条件は[tasks.md](tasks.md)のT-088以降を参照。

- [x] 設定にアプリ情報を置く
  - Task: T-088
- [ ] 本番向けの開発用導線を通常UIから外す
  - Task: T-089
- [ ] プライバシーポリシーとData safetyの下書き
  - Task: T-090
- [ ] Play掲載用の文言とスクリーンショット手順
  - Task: T-091
- [ ] Release署名とApp Bundle
  - Task: T-092
- [ ] Playの技術要件確認
  - Task: T-093
- [ ] Play提出前チェックリスト
  - Task: T-094
