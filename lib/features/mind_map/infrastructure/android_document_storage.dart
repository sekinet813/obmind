import 'package:flutter/services.dart';
import 'package:obmind/core/logging/app_logger.dart';
import 'package:obmind/features/mind_map/domain/repositories/mind_map_folder_picker.dart';
import 'package:obmind/features/mind_map/domain/repositories/mind_map_storage.dart';

/// Android SAF access. Presentation must not call this class's channel.
final class AndroidDocumentStorage
    implements MindMapStorage, MindMapFolderPicker {
  AndroidDocumentStorage({MethodChannel? channel, AppLogger? logger})
    : _channel = channel ?? const MethodChannel(channelName),
      _logger = logger ?? appLogger;

  static const channelName = 'dev.obmind.storage';

  final MethodChannel _channel;
  final AppLogger _logger;

  @override
  Future<MindMapLocation?> pickFolder() async {
    try {
      final token = await _channel.invokeMethod<String>('pickFolder');
      if (token == null || token.isEmpty) {
        return null;
      }
      return MindMapLocation(token);
    } on PlatformException catch (error, stackTrace) {
      _logger.error(
        'Android folder picker failed',
        error: error,
        stackTrace: stackTrace,
      );
      throw MindMapStorageException('failed to pick folder', cause: error);
    }
  }

  @override
  Future<MindMapFile> create(
    MindMapLocation folder,
    String displayName, {
    String markdown = '',
  }) async {
    try {
      final result = await _channel.invokeMapMethod<String, Object?>(
        'createMarkdown',
        {
          'folderToken': folder.token,
          'displayName': displayName,
          'markdown': markdown,
        },
      );
      final uri = result?['uri'] as String?;
      final name = result?['displayName'] as String? ?? displayName;
      if (uri == null || uri.isEmpty) {
        throw const MindMapStorageException('failed to create markdown');
      }
      return MindMapFile(location: MindMapLocation(uri), displayName: name);
    } on MindMapStorageException {
      rethrow;
    } on PlatformException catch (error, stackTrace) {
      _logger.error(
        'Android markdown create failed',
        error: error,
        stackTrace: stackTrace,
      );
      throw MindMapStorageException('failed to create markdown', cause: error);
    }
  }

  @override
  Future<List<MindMapFile>> list(MindMapLocation folder) {
    return Future.error(
      const MindMapStorageException(
        'list is not part of the Android folder PoC',
      ),
    );
  }

  @override
  Future<String> read(MindMapLocation location) {
    return Future.error(
      const MindMapStorageException(
        'read is not part of the Android folder PoC',
      ),
    );
  }

  @override
  Future<void> write(MindMapLocation location, String markdown) {
    return Future.error(
      const MindMapStorageException(
        'write is not part of the Android folder PoC',
      ),
    );
  }
}
