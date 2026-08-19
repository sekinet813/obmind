# アプリ識別子（ADR-0003）

- Status: Accepted
- Date: 2026-08-19

## 問題

テンプレート識別子（`app_template` / `com.example.app_template` / `com.example.appTemplate`）のままでは開発しづらい。一方、本番のApplication ID / Bundle IDはプロダクト全体に影響し、勝手に固定してはならない。

## 選択肢

1. 本番用の逆ドメイン名をいま決める
2. 表示名とDart packageだけ変え、OS識別子はテンプレートのまま残す
3. 開発用プレースホルダへリネームし、本番IDは未決定として残す

## 決定

選択肢3。

| 項目 | 値 | 扱い |
| --- | --- | --- |
| Dart package | `obmind` | 確定 |
| 表示名 | `Obmind` | 確定 |
| Android applicationId / namespace | `com.example.obmind` | 開発用プレースホルダ |
| iOS Bundle ID | `com.example.obmind` | 開発用プレースホルダ |

## TODO（人間）

本番のAndroid applicationIdとiOS Bundle IDを決める。決まるまでストア提出、正式なPush通知、Associated Domainsなどは行わない。

## Trade-off

- `com.example.*`のままではストア提出できない
- 本番IDへ変えるとき、開発端末の既存インストールとは別アプリになる
- テスト用Bundle ID（`com.example.obmind.RunnerTests`）もプレースホルダである
