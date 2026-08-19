# 長時間・夜間自律開発

Obmindでは、人間が`docs/tasks.md`を用意し、AIコーディングエージェントが未完了タスクを順番に実装・検証・コミットできます。フェーズの位置づけは`docs/roadmap.md`です。Codex Goal modeなどの長時間実行機能から使うことを想定していますが、ルール本体は`AGENTS.md`側の一般ルールです。

長時間実行は、人間によるレビューを不要にするものではありません。実装時間をAIへ委譲するための仕組みです。翌朝は必ず差分と動作を人間が確認してください。

## 手順

1. `docs/architecture.md`と`docs/roadmap.md`など、仕様を整理する
2. `docs/tasks.md`を作成・更新する。各タスクに完了条件を書く
3. 作業用branchを作成する。`main`では長時間実行しない
4. Codexなどのコーディングエージェントを起動する
5. 必要に応じてPrevent sleep while runningを有効化する
6. `prompts/overnight.md`をGoal modeなどへ貼り付けて長時間実行を開始する
7. 翌朝、`docs/tasks.md`と`git log` / `git diff`を確認する
8. BLOCKED項目を確認し、人間が判断する
9. 実機またはシミュレータで動作確認する。手順は`docs/mobile-testing.md`
10. 必要に応じて次のタスクを`docs/tasks.md`へ追加する

本番のApplication ID / Bundle IDなど人間の入力が必要なタスクは、値が決まってから夜間実行してください。未確定ならBLOCKEDにし、独立した機能タスクを進めます。タスク粒度の目安は30分から2時間で、実装・テスト・静的解析・コミットまで1タスクで完結できる単位に分割します。

## エージェントが行うこと

エージェントは次を繰り返します。

```text
TASKS確認
↓
次の実行可能タスクを選択
↓
仕様確認
↓
実装
↓
format
↓
analyze
↓
test
↓
必要なら修正
↓
TASKS更新
↓
commit
↓
次のタスク
```

あるタスクがBLOCKEDになっても、依存しない別タスクがあれば作業を続けます。すべてのタスクが完了、BLOCKED、またはBLOCKEDへの依存になった時点で終了します。

検証コマンドは既存プロジェクトと同じです。

```bash
dart format --set-exit-if-changed .
flutter pub get
flutter analyze
flutter test
```

Gitは原則1タスク1コミットです。push、merge、force pushはエージェントが勝手に行いません。

## 翌朝の確認

ログをすべて読み返さなくても、終了時のOvernight Development Summaryで状況を把握できます。そのうえで、人間は少なくとも次を確認してください。

- `git diff` / `git log`
- `docs/tasks.md`と`docs/roadmap.md`
- `flutter analyze`の結果
- `flutter test`の結果
- 実機またはシミュレータでの動作

確認後、BLOCKEDの解除、仕様の補充、次のタスク追加を行い、必要なら再度長時間実行します。
