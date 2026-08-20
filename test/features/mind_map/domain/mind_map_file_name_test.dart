import 'package:flutter_test/flutter_test.dart';
import 'package:obmind/features/mind_map/domain/mind_map_file_name.dart';

void main() {
  test('uses the default name when the folder is empty', () {
    expect(MindMapFileName.nextNewMapName(const []), '新規マインドマップ.md');
  });

  test('appends (1) when the default name is taken', () {
    expect(
      MindMapFileName.nextNewMapName(const ['新規マインドマップ.md']),
      '新規マインドマップ (1).md',
    );
  });

  test('fills a gap instead of skipping numbers', () {
    expect(
      MindMapFileName.nextNewMapName(const [
        '新規マインドマップ.md',
        '新規マインドマップ (2).md',
      ]),
      '新規マインドマップ (1).md',
    );
  });

  test('treats names with and without .md as the same file', () {
    expect(
      MindMapFileName.nextNewMapName(const ['新規マインドマップ']),
      '新規マインドマップ (1).md',
    );
  });

  test('increments past consecutive taken numbers', () {
    expect(
      MindMapFileName.nextNewMapName(const [
        '新規マインドマップ.md',
        '新規マインドマップ (1).md',
        '新規マインドマップ (2).md',
      ]),
      '新規マインドマップ (3).md',
    );
  });

  test('uses a localized base name and sequential suffixes', () {
    expect(
      MindMapFileName.nextNewMapName(const [], baseName: 'New Mind Map'),
      'New Mind Map.md',
    );
    expect(
      MindMapFileName.nextNewMapName(const [
        'New Mind Map.md',
      ], baseName: 'New Mind Map'),
      'New Mind Map (1).md',
    );
  });

  test('stem strips md and markdown extensions without changing case', () {
    expect(MindMapFileName.stem('新規マインドマップ.md'), '新規マインドマップ');
    expect(MindMapFileName.stem('Idea.MD'), 'Idea');
    expect(MindMapFileName.stem('Notes.markdown'), 'Notes');
  });
}
