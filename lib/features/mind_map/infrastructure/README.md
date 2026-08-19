# infrastructure

Markdownのparse / serializeと、OS固有ストレージ実装を置きます。

Androidのフォルダ選択PoCは`AndroidDocumentStorage`がSAFを扱います。PresentationとDomainはこの具象をimportしません。
