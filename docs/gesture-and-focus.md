# ジェスチャーとフォーカス

Phase 6の入力ルールです。Pan / Zoomは`InteractiveViewer`、Node操作はViewport上の`GestureDetector`が担当します。

## ジェスチャー役割

| 操作 | 役割 |
| --- | --- |
| 1本指ドラッグ（空白またはNode上） | Pan |
| Pinch | Zoom |
| Nodeタップ | 選択 |
| Node長押し＋ドラッグ | 並び替え / 親変更（Panは無効） |
| Nodeダブルタップ | インライン編集開始 |
| 編集中 | Pan / Zoomは有効。Nodeタップは編集確定後に選択 |

Node DragによるReorder / Move Parentは、Node長押し後のドラッグで開始します。Drag中は`InteractiveViewer`のPan / Zoomを止め、Panとの競合を避けます。

## フォーカス

- Node選択状態はPresentationのみ。Markdownへ保存しません
- インライン編集は選択中Node上の`TextField`で行い、Dialogや別画面へ遷移しません
- 編集`FocusNode`はViewportが保持し、キーボード表示中も`InteractiveViewer`でPan / Zoomできます
- `MindNodeWidget`には`Semantics` labelを付け、VoiceOver / TalkBackでNode textを読み上げます
