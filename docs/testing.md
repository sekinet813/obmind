# テスト方針

コード変更後は、環境上実行可能な範囲で次を成功させます。

```bash
dart format --set-exit-if-changed .
flutter pub get
flutter analyze
flutter test
```

Android実装を変えた場合は可能なら`flutter build apk --debug`、iOS実装を変えた場合は可能なら`flutter build ios --debug --no-codesign`も確認します。

実機への配布とインストール手順は[mobile-testing.md](mobile-testing.md)です。

## Unit Test

### Markdown（Phase 2）

- Markdown → Parse → `MindMapDocument`
- `MindMapDocument` → Serialize → Markdown
- Parse → Serialize → Parse でTree、text、ID、順序、collapsed、theme / layoutが維持されること
- ID欠落ファイルにIDが採番されること
- 未対応ブロックを黙って捨てないこと（警告または失敗）

### Tree操作（Phase 2）

- Add / Delete / Move / Reorder
- Cycle防止
- idの一意性

### Domain Model（Phase 0）

- `MindNode` / `MindMapDocument`の生成とcopy
- childrenの順序
- 文書内のid一意
- Rootは1つ
- UI座標フィールドがモデルに無いこと（レビュー観点）

### Layout（Phase 3）

同一Inputに対して安定した`NodeLayout`になること。

## Widget Test

最低限、次を対象にします。Phase 0ではプレースホルダホームのみです。

- Node表示
- Node選択
- Node追加
- Node編集

ホーム画面の表示も、識別子変更の回帰として維持します。

## 日付とID

IDには表示名ではなく不変IDを使います。日付を扱う場合は内部表現を統一し、タイムゾーンの曖昧さを避けます。

## Logging

テストや本番コードで`print()`を無秩序に使いません。
