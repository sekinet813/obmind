# モバイルでの動作確認

AndroidはローカルPCでビルドしなくても、GitHub ActionsのDebug APK Artifactを使って実機確認できます。iOSは標準では署名なしビルド確認までとし、実機確認はローカルのシミュレータまたはXcodeで行います。

## Android: Artifactからインストール

1. 実装してGitHubへpush / PR作成、または`main`へmergeする
2. GitHub Actionsで以下を実行する
   - `flutter pub get`
   - `flutter analyze`
   - `flutter test`
   - `flutter build apk --debug`
3. `<リポジトリ名>-debug-apk`という名前で`app-debug.apk`をWorkflow Artifactとして7日間保存する
4. Androidスマートフォンから対象PRまたは`Actions`タブのWorkflow Runを開く
5. Runの`Artifacts`欄からダウンロードして展開する
6. `app-debug.apk`を端末へインストールする

方針:

- Debug APKは開発中の実機確認用途とする
- Play Store配布やRelease署名はこのリポジトリの標準対象外とする
- CIで静的解析・テストが失敗した場合は、APK配布まで進めない
- Artifactの保持期間は7日間とし、長期保管を目的としない
- APKそのものをGitリポジトリへコミットしない
- 失敗したWorkflow RunのArtifactを、新しい成功分と取り違えない

インストール時の注意:

- GitHub Actionsが成功し、同じWorkflow Run内で生成されたArtifactであることを確認する
- Androidで初めてブラウザやファイル管理アプリからAPKを開く場合は、「不明なアプリのインストール」を一時的に許可する必要がある
- Debug APKは開発用署名であり、Play Store配布版として扱わない
- 同じapplicationIdの古いDebug APKが残っている場合は、一度アンインストールしてから入れ直す
- 確認後は必要に応じて「不明なアプリのインストール」の許可を解除する

## Android folder picker PoC

ホーム画面の「フォルダを選んでMarkdownを作成」から、SAFのフォルダ選択でDocumentsなどを選び、その場所へ`新規マインドマップ.md`が作られることを確認します。同名がある場合は`新規マインドマップ (1).md`のように空き番号を使います。作成後に編集画面が開き、読み込み・編集・自動保存ができることも確認します。保存に失敗した場合、元のファイルが空にならないことを確認します。PresentationはSAFを直接呼びません。

## iOS: ローカル確認

CIのmacOSジョブは`flutter build ios --debug --no-codesign`でコンパイルできることだけを確認します。署名がないため、この成果物はiPhoneへ直接インストールできません。

ローカル確認:

```bash
flutter pub get
flutter run
```

- シミュレータがある場合は`flutter run`で起動する
- 実機の場合はXcodeでSigning & Capabilitiesに開発用チームを設定してから実行する

## 後からIPAをCIで配る場合

GitHub-hosted runnerからインストール可能なIPAを出すには、Apple Developerの証明書とProvisioning Profileが必要です。

コピー後に足す場合の要点:

1. 証明書とProfileをGitHub Actionsのsecretsへ格納する
2. macOSジョブで署名して`flutter build ipa`相当を実行する
3. 成功時のみArtifactまたは内部配布先へアップロードする
4. secretsが無いリポジトリでは、署名なしビルド確認のままにする

このリポジトリはsecretsを前提にしないため、標準ではIPA Artifactを出しません。
