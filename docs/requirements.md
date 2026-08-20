# 要件

Obmindは、Markdownファイルを正本とするLocal-firstなマインドマップアプリです。このファイルはMVPの範囲と非対象を固定します。詳細なデータ形式は[markdown-format.md](markdown-format.md)、実装方針は[architecture.md](architecture.md)を参照してください。

## Product Principle

> Obmindは、思考を囲い込むサービスではない。
>
> 思考を気持ちよく整理するための道具である。
>
> データはユーザーのもの。
>
> Obmindがなくなっても、その思考はMarkdownとして残る。

## 優先順位

判断に迷った場合は、上から順に優先します。

1. ユーザーデータを失わない
2. Markdown互換性
3. UI / UX
4. シンプルなArchitecture
5. Performance
6. 機能数

機能数を増やすことより、安全で気持ちよく長く使えるマインドマップを優先します。

## 設計原則

### Markdown is Source of Truth

マインドマップの正本はMarkdownファイルです。SQLiteなどのローカルDBを使う場合も、キャッシュ・インデックス・UI状態・検索用データに限定します。アプリをアンインストールしてローカルDBが失われても、Markdownから復元できる状態を維持します。

### Local-first

基本的な作成・編集はオフラインで使えます。MVPではObmind専用バックエンドを持ちません。

### ユーザーがデータを所有する

ファイルはユーザーが選んだ場所に保存します。想定はアプリローカル、Obsidian Vault、iCloud Drive、Android Document Provider経由のフォルダです。Obsidianは重要なユースケースですが、Obsidian専用アプリにはしません。

### Markdownを意識させないUI

内部データはMarkdownでも、通常利用でMarkdown編集を要求しません。体験はグラフィカルなマインドマップです。

### UI / UXを最重要視する

競争力の中心はスマートフォンでマインドマップを描く体験です。操作の気持ちよさ、アニメーション、見た目、ノード編集のしやすさ、Pan / Zoom、Drag & Drop、応答速度を、機能数より優先します。

## ターゲット

Obsidianユーザー、Markdownユーザー、PKMに関心がある人、スマホでマインドマップを作りたい人、サブスク型サービスやデータロックインを避けたい人を主な対象とします。ただしMarkdownやObsidianの知識を利用の前提にしません。

## 対応Platform

MVPはiOSとAndroidです。Web / macOS / Windowsは対象外です。Domain層などは将来のマルチプラットフォームを阻害しない設計にします。

## MVP機能

### マインドマップ管理

- 新規作成
- 一覧
- 開く
- 名前変更
- 削除
- Markdownとして保存
- Markdownから読み込み

### ノード操作

- Root表示
- Child追加
- Sibling追加
- 編集
- 削除
- 並び替え
- 親の変更
- 折りたたみ / 展開

ノード編集は、可能な限りキャンバスから離れずに行えるUIとします。

## データ構造

MVPのマインドマップはTreeです。各NodeのParentは最大1つです。任意Node間のEdgeによるGraphは扱いません。

## レイアウト

自動レイアウトを基本とします。ユーザーが自由座標へ置く方式は採用しません。NodeのDragは並び替えまたはParent変更として解釈します。アプリから新規作成した地図の既定レイアウトは放射（Radial）です。`layout`未指定の既存ファイルはHorizontalのままです。ユーザーはHorizontalへ切り替えられます。Layout EngineはUI Widgetから独立させます。

## Pan / Zoomと編集画面

マインドマップ画面では1本指Pan、Pinch Zoom、Double Tap Zoom、Fit to Screen、Node Tap / Long Press / Dragを扱います。常時表示UIは最小限にし、選択時のみContext Actionを出します。

## 描画

EdgeはCustomPainter、NodeはFlutter Widgetとします。すべてをCustomPainterだけで実装しません。将来のViewport Cullingを阻害しない構造にします。MVPでは100〜200 Node程度の快適さを優先します。

## ファイルと保存

ファイルアクセスは抽象化します。Android SAFやiOS Document Picker、iCloud、ObsidianをDomain / Applicationから直接参照しません。

Autosaveを基本としますが、入力のたびに即Disk Writeはしません。debounceとatomic writeを使い、保存中の強制終了でもMarkdownが壊れにくいようにします。外部変更の高度なConflict ResolutionはMVP対象外ですが、無条件上書きする構造にはしません。

## Undo / Redo

Add、Delete、Edit、Move、Reorder、Collapse / Expandを対象にします。Command Patternは検討しますが、設計を過度に複雑にしません。

## Theme

MindMapThemeを差し替え可能にします。MVPの候補はMinimal、Soft、Darkです。課金実装は不要ですが、後からFree / Proへ分けやすい構造にします。データアクセスそのものを過度に課金対象にしません。

## MVP対象外

次は初期実装で行いません。

- 独自クラウド
- ユーザーアカウント
- リアルタイム共同編集
- Web版 / Desktop版
- AI
- 任意Graph
- 自由座標配置
- 画像Node / 添付 / コメント
- SNS / チーム機能
- 高度なMarkdown完全互換Parser
- 課金実装

プロダクト全体へ影響する判断（Markdown Formatの破壊的変更、独自Backend、Firebase、User Account、Cloud Storage、課金方式、本番Application ID / Bundle ID、自由配置、Graph化）は勝手に固定しません。問題・選択肢・推奨・Trade-offをADRに残します。
