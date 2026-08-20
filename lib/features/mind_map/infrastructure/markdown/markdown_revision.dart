import 'dart:convert';

import 'package:obmind/features/mind_map/domain/repositories/mind_map_storage.dart';

/// Computes an opaque [MindMapRevision] from Markdown content.
///
/// Infrastructure uses this so Application can detect external edits without
/// storing OS mtimes in Domain.
final class MarkdownRevision {
  const MarkdownRevision._();

  static MindMapRevision fromMarkdown(String markdown) {
    final digest = sha256LikeDigest(utf8.encode(markdown));
    return MindMapRevision('v1:$digest');
  }

  /// Small stable digest without adding the `crypto` package.
  static String sha256LikeDigest(List<int> bytes) {
    var h1 = 0xcbf29ce484222325;
    var h2 = 0x14650fb0739d0383;
    for (final byte in bytes) {
      h1 = (h1 ^ byte) * 0x100000001b3;
      h2 = (h2 ^ byte) * 0x100000001b3;
      h1 &= 0xFFFFFFFFFFFFFFFF;
      h2 &= 0xFFFFFFFFFFFFFFFF;
    }
    return base64Url.encode([
      (h1 >> 56) & 0xff,
      (h1 >> 48) & 0xff,
      (h1 >> 40) & 0xff,
      (h1 >> 32) & 0xff,
      (h1 >> 24) & 0xff,
      (h1 >> 16) & 0xff,
      (h1 >> 8) & 0xff,
      h1 & 0xff,
      (h2 >> 56) & 0xff,
      (h2 >> 48) & 0xff,
      (h2 >> 40) & 0xff,
      (h2 >> 32) & 0xff,
      (h2 >> 24) & 0xff,
      (h2 >> 16) & 0xff,
      (h2 >> 8) & 0xff,
      h2 & 0xff,
    ]);
  }
}
