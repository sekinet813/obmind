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

## Playの技術要件（確認日: 2026-08-20）

DomainとMarkdown Formatは変更していません。Gradle / AGP / Kotlinの大規模アップグレードもしていません。Flutterがビルド時に出した「まもなく古い」警告は残しています。

### 使用中のSDK

| 項目 | 値 | 出所 |
| --- | --- | --- |
| Flutter | 3.47.0（framework `4cf2416426`、2026-08-11） | `flutter --version` |
| compileSdk | 36（`flutter.compileSdkVersion`） | Flutter Gradle extension |
| targetSdk | 36（`flutter.targetSdkVersion`） | 同上 |
| minSdk | 24 | 同上 |
| NDK | 28.2.13676358（`flutter.ndkVersion`） | 同上。r28系は16KBアラインが既定 |
| AGP | 8.11.1 | `android/settings.gradle.kts` |
| Gradle | 8.14 | `android/gradle/wrapper/gradle-wrapper.properties` |
| Kotlin | 2.2.20 | `android/settings.gradle.kts` |
| applicationId | `com.example.obmind`（開発用） | T-007未決 |

### Playのtarget API

[Playのtarget API要件](https://support.google.com/googleplay/android-developer/answer/11926878)では、2026-08-31以降の新規アプリと更新はAndroid 16（API 36）以上が必要です。本プロジェクトはtargetSdk 36なので、この項目は満たしています。不足時の上げ方は、まずFlutterチャネルを上げて`flutter.targetSdkVersion`に乗せる。`targetSdk`だけを手で上げない。判断が必要なら人間レビュー。

### 16KBページサイズ

[Androidの16KB案内](https://developer.android.com/guide/practices/page-sizes)とPlayの方針では、API 35以上の64bit向けにネイティブライブラリが16KBページをサポートする必要があります。更新のブロック期限は案内により2027-02-01頃。NDK r28以上が推奨です。

確認（debug APK `build/app/outputs/flutter-apk/app-debug.apk`、2026-08-20）:

1. `zipalign -c -P 16 -v 4` → Verification successful（build-tools 36.1.0）
2. 含まれる`.so`のPT_LOAD `p_align`はいずれも`0x4000`（16KB）以上
   - 64bit: `libflutter.so` / `libdatastore_shared_counter.so` / debug用`libVkLayer_khronos_validation.so`
   - 32bit `armeabi-v7a`も同様に16KB以上だったが、Playが主に見るのは64bit

Release AABはdebug APKと中身が違う（Vulkan validation層は通常入らない）。提出前に人間が`flutter build appbundle`の成果物で同じ確認をする。

```bash
# APKまたはunzipしたAAB内の .so に対して
zipalign -c -P 16 -v 4 app-release.apk
# ELFのLOAD Alignが 0x4000 以上であること（readelf -l または Androidのcheck_elf_alignment.sh）
```

不足していた場合の上げ方（今回は実施しない）: Flutterを上げて`ndkVersion = flutter.ndkVersion`を維持する。古いNDKを`build.gradle.kts`へ直書きしない。プラグインが古い`.so`を同梱していたらそのパッケージを更新する。AGP 9 / Gradle 9への一括上げはPlay要件の必須ではないため、警告があってもこのタスクでは触らない。

### 残課題（人間作業）

- 署名済みRelease AABでの16KB再確認
- Play Consoleが提出時点で示すtarget API / page sizeの表示との突き合わせ

## Play提出前チェックリスト

人間がPlay Consoleで行う作業と、アプリ側の前提です。エージェントは提出ボタンを押さず、本番applicationIdも決めません。チェックを埋めること自体は人間作業です。

### アプリ側（提出の前提）

- [ ] T-007: 本番のAndroid applicationIdが設定済みである。開発用`com.example.obmind`のまま提出しない。Bundle IDは[ADR-0003](decisions/ADR-0003-identifiers.md)
- [ ] Release AABが本番IDかつupload鍵（`android/key.properties`）で署名されている。debug署名や`key.properties`無しのAABは使わない
- [ ] 署名済みAABで16KBページサイズを再確認した（上記の手順）
- [ ] Android実機でMVPの基本操作を確認した（T-048）。手順は[mobile-testing.md](mobile-testing.md)

### Play Console（人間作業）

- [ ] デベロッパーアカウントとPlay App Signing
- [ ] 内部テストトラック（またはクローズドテスト）へAABをアップロード
- [ ] プライバシーポリシーの公開URLを設定した。文面は[privacy-policy.md](privacy-policy.md)。アプリ内設定からも読める
- [ ] Data safetyを申告した。収集・共有なし、ファイルアクセスの目的はマインドマップの保存
- [ ] コンテンツレーティングの質問票
- [ ] アプリのカテゴリと連絡先メール
- [ ] 短い説明・詳細説明を転記した。「正本」は使わない
- [ ] 高解像度アイコン（512×512）、フィーチャーグラフィック（1024×500）、Phoneスクリーンショット（2枚以上）
- [ ] targetSdk 36と16KBのConsole表示が要件を満たす

提出完了は人間の判断です。このチェックリストの文書化をもってT-094は完了とします。


