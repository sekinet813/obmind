# application

ノード操作、Load/Save、Undo/Redoなどのユースケースと、Layout Engineを置きます。

Layout EngineはWidgetから独立し、`MindMapDocument`から`NodeLayout`を計算します。座標はDomainのNodeへ保存しません。

Phase 0ではLayout Engineの契約だけを定義します。Horizontal Layoutの実装はPhase 3です。
