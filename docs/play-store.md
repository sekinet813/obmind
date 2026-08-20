# Play Store掲載準備

ストア掲載の文言下書きと、画像のサイズ・撮影手順です。提出操作そのものは人間作業です。実機スクリーンショットとフィーチャーグラフィックの画像ファイルは、このタスク時点では未撮影です（残課題）。

アプリ内・ストア掲載では「正本」という語を使いません。思考はMarkdownファイルとして残ると書きます。

関連: [privacy-policy.md](privacy-policy.md)、[mobile-testing.md](mobile-testing.md)

## 短い説明（80文字以内）

```text
思考はMarkdownファイルとして残る、Local-firstなマインドマップ。アカウント不要。
```

文字数: 49（提出前にPlay Consoleのカウンタで再確認する）

## 詳細説明

```text
Obmindは、思考を気持ちよく整理するためのマインドマップアプリです。アカウントは不要です。独自のクラウドへ思考を預けることはありません。

地図はMarkdownファイルとして、あなたが選んだフォルダに残ります。Obmindがなくなっても、ファイルはその場所にあります。ObsidianのVaultなど、普段使っているフォルダを保存先にできます。Obsidian専用アプリではありません。

スマートフォンでの描画を優先しています。ピンチで拡大縮小し、ノードをタップして編集できます。子や兄弟の追加、折りたたみ、元に戻す／やり直す、自動保存に対応します。レイアウトは水平と放射を切り替えられます。見た目はペーパー、インク、ダーク、ミニマルの4種です。デザインを変えてもレイアウトは変わりません。

はじめて開くと、思考の保存フォルダを選びます。選んだフォルダのMarkdownだけを読み書きします。選んでいない場所へはアクセスしません。

オフラインで使えます。思考はあなたのファイルです。
```

提出前にPlayの4000文字制限と禁止表現（他アプリのランキング比較、保証しすぎる表現）を確認する。

## 必要な画像サイズ

提出時点のPlay Console表示を優先する。目安は次のとおり。

| 種類 | サイズ | 形式の目安 |
| --- | --- | --- |
| 高解像度アイコン | 512×512 | 32-bit PNG（透過可）。マスターは`assets/brand/app_icon.png`（1024×1024相当）から縮小 |
| フィーチャーグラフィック | 1024×500（厳密） | JPEGまたは24-bit PNG。透過なし。15MB以下 |
| Phoneスクリーンショット | 最短辺320以上、最長辺3840以下。最長は最短の2倍以内。推奨1080×1920 | JPEGまたは24-bit PNG。透過なし。2枚以上8枚以下。推奨は4枚以上 |

タブレット用スクリーンショットは、Phoneのみで出すなら必須ではない。フィーチャーグラフィックは掲載に必要。重要な文字は中央寄り（端から約100px内側）に置く。

## 撮影すべき画面

実機またはAndroidエミュレータで、ステータスバーの個人情報（通知、キャリア名）が写らないよう注意する。開発用のPoCボタンは通常UIに出ない（T-089）。

1. オンボーディング: 保存フォルダ未設定。「思考の保存フォルダを選ぶ」と本文が見える状態
2. 一覧: 保存フォルダ設定済み。いくつかMarkdownがあるリスト（またはタイル）
3. 放射マップ: ノードが放射状に広がった編集画面。全体が把握できるズーム
4. テーマ違い: 同じ地図でペーパー／インク／ダーク／ミニマルのうち、少なくともペーパーとダーク（可能なら4種）
5. 編集: ノードを選択してテキスト編集中。自動保存が表示されていてもよい。保存ボタンは出ない

撮影順の例: 空の端末で起動 → 1 → フォルダを選ぶ → 地図を2〜3個作る → 2 → 放射で開く → 3 → デザインを切り替えて 4 → ノードを編集して 5。

水平レイアウトの1枚を足してもよい。ストア文言と矛盾しないこと（デザイン変更でレイアウトは変わらない）。

## フィーチャーグラフィックの作り方

未作成。人間が次で作る。

- 背景はブランドのクリーム（`#F5F0E6`）
- `assets/brand/app_icon.png`と「Obmind」を中央付近に置く
- 短い説明に近い一文を足してよい。例: 「思考はMarkdownファイルとして残る」
- 「正本」は使わない
- 透過なしの1024×500で書き出す

## 残課題（人間作業）

- Phoneスクリーンショットの実撮影とPlay Consoleへのアップロード
- フィーチャーグラフィックの作成とアップロード
- 512×512アイコンの書き出し（マスターから）
- 短い説明・詳細説明のConsole転記と、提出時点の文字数確認

## Release署名とApp Bundle

Playへの新規公開はAAB（`.aab`）が基本です。debug署名のAABは提出しない。keystoreとパスワードはリポジトリに置きません。

### 人間が一度だけ行う鍵の用意

エージェントはkeystoreを発行しません。提出する人が手元で作り、`android/key.properties`へパスを書きます。サンプルは`android/key.properties.example`です。

```bash
keytool -genkey -v -keystore /absolute/path/to/obmind-upload.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

`android/key.properties.example`を`android/key.properties`へコピーし、パスワードと`storeFile`を埋めます。`key.properties`、`*.jks`、`*.keystore`はgitignore済みです。

本番のapplicationIdはT-007（[ADR-0003](decisions/ADR-0003-identifiers.md)）が未決のままです。AABを作る配線は開発用`com.example.obmind`でも確認できますが、Playへ出すAABは本番IDと本番（upload）鍵で署名します。

### AABのビルド

`android/key.properties`があるマシンで:

```bash
flutter pub get
flutter build appbundle
```

成果物は`build/app/outputs/bundle/release/app-release.aab`です。Play Consoleの内部テストトラックなどへアップロードします。Play App Signingを使う場合、ここで使うのはupload鍵です。

`key.properties`が無いと、releaseはdebug鍵のままになります。`flutter run --release`用のフォールバックであり、そのAABは提出しないでください。

keystore未作成は人間作業の残課題です。CIのDebug APK手順は従来どおり[mobile-testing.md](mobile-testing.md)です。
