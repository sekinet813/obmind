# ジェスチャーとフォーカス

Phase 6の入力ルールです。Pan / Zoomは`InteractiveViewer`、Node操作はViewport上の`GestureDetector`が担当します。

## ジェスチャー役割

| 操作 | 役割 |
| --- | --- |
| 1本指ドラッグ（空白またはNode上） | Pan |
| Pinch | Zoom |
| キャンバス上の拡大 / 縮小ボタン | ビューポート中心で段階ズーム（min / max scaleを維持） |
| 中心へ戻る | Rootを読みやすい縮尺で画面中央へ戻す。全体表示（Fit to Screen）とは別 |
| Nodeタップ | 選択 |
| Node長押し＋ドラッグ | 並び替え / 親変更（Panは無効） |
| Node上の+ / - | 子を持つNodeの折りたたみ / 展開。下部メニューからも同じ操作ができる |
| 編集中 | Pan / Zoomは有効。完了ボタン・キャンバス空白Tap・他Node Tap・キーボードDoneで編集終了。Drag / DoubleTapは無効 |

Node DragによるReorder / Move Parentは、Node長押し後のドラッグで開始します。Drag中は`InteractiveViewer`のPan / Zoomを止め、Panとの競合を避けます。

## フォーカス

- Node選択状態はPresentationのみ。Markdownへ保存しません
- インライン編集は選択中Node上の`TextField`で行い、Dialogや別画面へ遷移しません
- 編集`FocusNode`はViewportが保持し、キーボード表示中も`InteractiveViewer`でPan / Zoomできます
- `MindNodeWidget`には`Semantics` labelを付け、VoiceOver / TalkBackでNode textを読み上げます
