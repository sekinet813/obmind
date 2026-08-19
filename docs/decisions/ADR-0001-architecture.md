# アーキテクチャ（ADR-0001）

- Status: Accepted
- Date: 2026-08-19

## 問題

テンプレートは`presentation/` `domain/` `data/` `infrastructure/`のレイヤー分割だった。Obmindはマインドマップ、ライブラリ、設定など機能が増える。状態管理の候補としてRiverpodがある。いま導入すべきかを決める必要がある。

## 選択肢

1. テンプレートのレイヤー分割を維持する
2. Feature-firstにし、各featureの中でdomain / application / infrastructure / presentationを分ける
3. いまRiverpodを入れて全体をProvider化する

## 決定

Feature-first（選択肢2）を採用する。テンプレートのData層は各featureのinfrastructureへ吸収する。

Riverpodは第一候補のまま、Phase 0では導入しない。

## 理由

- マインドマップとライブラリで寿命と依存が違う
- DomainをFlutterから離す目的は、レイヤー名より依存方向で達成できる
- 最新の`flutter_riverpod` 3.4.xはDart SDK `>=3.12`を要求し、本リポジトリの`>=3.10.0`と合わない
- UI状態がまだ無い段階で依存を増やさない

## Trade-off

- featureをまたぐ共通処理は`lib/core`か`lib/app`へ寄せる必要があり、置き場所の判断が増える
- Riverpod導入時に`pubspec`のSDK下限またはパッケージ版の見直しが必要になる

## 後続

描画や編集の状態が必要になった時点で、そのときのFlutter / Dartに合うRiverpodを入れる。UIの一時StateとDomain Stateは混ぜない。
