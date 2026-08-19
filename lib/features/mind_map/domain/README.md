# domain

マインドマップのモデルと`MindMapStorage` interfaceを置きます。Add / Delete / Move / Reorderは`MindMapTree`が不変な`MindMapDocument`を返します。

この層はFlutter Widget、ファイルシステム、Android / iOSのOS APIへ依存しません。Nodeへ画面座標を持たせません。フォルダ選択は`MindMapFolderPicker`、読み書きは`MindMapStorage`です。
