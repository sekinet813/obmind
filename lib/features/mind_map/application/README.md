# application

ノード操作、Load/Save、Undo/Redoなどのユースケースと、Layout Engineを置きます。

Layout EngineはWidgetから独立し、`MindMapDocument`から`NodeLayout`を計算します。座標はDomainのNodeへ保存しません。

`CreateMarkdownInFolder`はフォルダ選択とMarkdown作成をOrchestrationします。OSのPicker UIはInfrastructure側です。

`LoadMindMap`と`SaveMindMap`はParser / Serializerと`MindMapStorage`を結び、マインドマップ画面とMarkdownファイルを往復します。

`AutosaveMindMap`は`SaveMindMap`をdebounceし、編集のたびに即Disk Writeしません。atomic writeはInfrastructure側です。

`HorizontalLayoutEngine`は左から右へ子を置き、折りたたまれた子孫はレイアウトから省きます。`RadialLayoutEngine`はRootの子を円周へ等間隔に置き、孫以降はその枝の外側へ一方向に伸ばします。Root中心はLayout原点に固定し、子の増減でRoot座標が飛びません。座標はDomainのNodeへ書き戻しません。
