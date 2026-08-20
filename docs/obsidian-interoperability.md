# Obsidian Vaultでの確認

Format v0.1のMarkdownはObsidian Vault内の通常ファイルとして扱えます。Obmind専用APIには依存しません。

## 手順

1. Obsidian Vault内の任意フォルダをAndroidでSAF経由で選ぶ
2. Obmindでマインドマップを作成または既存`.md`を開く
3. 子Node追加・折りたたみ・保存を行う
4. Obsidianで同じファイルを開き、Tree構造と本文が壊れていないことを確認する
5. Obsidian側で見出し下にWikiLink付きリストを追記し、Obmindで再度開いてParser警告の有無を確認する

未対応ブロックがある場合、Obmindはread-onlyで開き上書き保存を止めます。
