# application

ノード操作、Load/Save、Undo/Redoなどのユースケースと、Layout Engineを置きます。

Layout EngineはWidgetから独立し、`MindMapDocument`から`NodeLayout`を計算します。座標はDomainのNodeへ保存しません。

`CreateMarkdownInFolder`はフォルダ選択とMarkdown作成をOrchestrationします。OSのPicker UIはInfrastructure側です。

Horizontal Layoutの実装はPhase 3です。
