import 'package:flutter_test/flutter_test.dart';
import 'package:obmind/features/mind_map/application/layout/horizontal_layout_engine.dart';
import 'package:obmind/features/mind_map/application/layout/layout_engines.dart';
import 'package:obmind/features/mind_map/application/layout/radial_layout_engine.dart';
import 'package:obmind/features/mind_map/domain/models/layout_type.dart';

void main() {
  test('selects the engine that matches LayoutType', () {
    expect(
      layoutEngineFor(LayoutType.horizontal),
      isA<HorizontalLayoutEngine>(),
    );
    expect(layoutEngineFor(LayoutType.radial), isA<RadialLayoutEngine>());
  });
}
