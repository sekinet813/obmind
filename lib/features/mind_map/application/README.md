# application

ノード操作、Load/Save、Undo/Redoなどのユースケースと、Layout Engineを置きます。

Layout EngineはWidgetから独立し、`MindMapDocument`から`NodeLayout`を計算します。座標はDomainのNodeへ保存しません。

`CreateMarkdownInFolder`はフォルダ選択とMarkdown作成をOrchestrationします。OSのPicker UIはInfrastructure側です。

`HorizontalLayoutEngine`は左から右へ子を置き、折りたたまれた子孫はレイアウトから省きます。座標はDomainのNodeへ書き戻しません。
