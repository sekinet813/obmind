# presentation

MindMapViewport、EdgeLayer、NodeWidgetを置きます。Phase 3以降です。

`MindNodeWidget`はNodeの見た目だけを描きます。座標はWidgetに持たせず、Viewportが`NodeLayout`を使って配置します。

`MindMapEdgeLayer`は`CustomPainter`で親子のEdgeを描きます。Layoutに無い子孫へは線を引きません。

`MindMapPage`は選択中のNodeへ子・兄弟を追加します。操作は`MindMapTree`を通し、Rootの兄弟は追加できません。

Phase 1のStorage PoCでは、Markdownの読み書き確認用に簡単な編集画面を置きます。
