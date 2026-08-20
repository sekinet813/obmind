import 'package:obmind/features/mind_map/application/layout/horizontal_layout_engine.dart';
import 'package:obmind/features/mind_map/application/layout/layout_engine.dart';
import 'package:obmind/features/mind_map/application/layout/radial_layout_engine.dart';
import 'package:obmind/features/mind_map/domain/models/layout_type.dart';

/// Returns the layout engine for a document's [LayoutType].
LayoutEngine layoutEngineFor(LayoutType layout) {
  return switch (layout) {
    LayoutType.horizontal => const HorizontalLayoutEngine(),
    LayoutType.radial => const RadialLayoutEngine(),
  };
}
