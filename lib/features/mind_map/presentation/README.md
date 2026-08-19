# presentation

MindMapViewport、EdgeLayer、NodeWidgetを置きます。Phase 3以降です。

`MindNodeWidget`はNodeの見た目だけを描きます。座標はWidgetに持たせず、Viewportが`NodeLayout`を使って配置します。

`MindMapEdgeLayer`は`CustomPainter`で親子のEdgeを描きます。Layoutに無い子孫へは線を引きません。

`MindMapViewport`はLayout結果でNodeとEdgeを配置し、`InteractiveViewer`で1本指PanとPinch Zoomします。選択状態はViewportの引数であり、Markdownへ書きません。

Phase 1のStorage PoCでは、Markdownの読み書き確認用に簡単な編集画面を置きます。
