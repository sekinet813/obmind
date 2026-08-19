# mind_map

マインドマップの中核featureです。

- `domain/`: Flutterに依存しないモデルとStorage interface
- `application/`: Layout Engine interface。ノード操作・Load/Save・UndoはPhase 4以降
- `infrastructure/`: Markdown Parser / Serializerとファイル実装（Phase 1〜2）
- `presentation/`: ViewportとNode Widget（Phase 3以降）
