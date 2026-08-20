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
  Future<bool> hasAccess(MindMapLocation folder) async {
    try {
      final granted = await _channel.invokeMethod<bool>('hasFolderAccess', {
        'folderToken': folder.token,
      });
      return granted ?? false;
    } on PlatformException catch (error, stackTrace) {
      _logger.error(
        'Android folder access check failed',
        error: error,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  @override
  Future<MindMapFile> create(
    MindMapLocation folder,
    String displayName, {
    String markdown = '',
  }) async {
    try {
      final result = await _channel
          .invokeMapMethod<String, Object?>('createMarkdown', {
            'folderToken': folder.token,
            'displayName': displayName,
            'markdown': markdown,
          });
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
  Future<MindMapFile> rename(
    MindMapLocation location,
    String newDisplayName,
  ) async {
    try {
      final result = await _channel.invokeMapMethod<String, Object?>(
        'renameMarkdown',
        {'fileToken': location.token, 'displayName': newDisplayName},
      );
      final uri = result?['uri'] as String?;
      final name = result?['displayName'] as String? ?? newDisplayName;
      if (uri == null || uri.isEmpty) {
        throw const MindMapStorageException('failed to rename markdown');
      }
      return MindMapFile(location: MindMapLocation(uri), displayName: name);
    } on MindMapStorageException {
      rethrow;
    } on PlatformException catch (error, stackTrace) {
      _logger.error(
        'Android markdown rename failed',
        error: error,
        stackTrace: stackTrace,
      );
      throw MindMapStorageException(
        error.message ?? 'failed to rename markdown',
        cause: error,
      );
    }
  }

  @override
  Future<void> delete(MindMapLocation location) async {
    try {
      await _channel.invokeMethod<void>('deleteMarkdown', {
        'fileToken': location.token,
      });
    } on PlatformException catch (error, stackTrace) {
      _logger.error(
        'Android markdown delete failed',
        error: error,
        stackTrace: stackTrace,
      );
      throw MindMapStorageException(
        error.message ?? 'failed to delete markdown',
        cause: error,
      );
    }
  }

  @override
  Future<List<MindMapFile>> list(MindMapLocation folder) async {
    try {
      final rows =
          await _channel.invokeListMethod<Map<Object?, Object?>>(
            'listMarkdown',
            {'folderToken': folder.token},
          ) ??
          const [];
      return rows
          .map((row) {
            final uri = row['uri'] as String?;
            final name = row['displayName'] as String? ?? uri ?? '';
            if (uri == null || uri.isEmpty) {
              throw const MindMapStorageException('invalid list entry');
            }
            return MindMapFile(
              location: MindMapLocation(uri),
              displayName: name,
            );
          })
          .toList(growable: false);
    } on MindMapStorageException {
      rethrow;
    } on PlatformException catch (error, stackTrace) {
      _logger.error(
        'Android markdown list failed',
        error: error,
        stackTrace: stackTrace,
      );
      throw MindMapStorageException('failed to list markdown', cause: error);
    }
  }

  @override
  Future<String> read(MindMapLocation location) async {
    try {
      final markdown = await _channel.invokeMethod<String>('readMarkdown', {
        'fileToken': location.token,
      });
      if (markdown == null) {
        throw const MindMapStorageException('failed to read markdown');
      }
      return markdown;
    } on MindMapStorageException {
      rethrow;
    } on PlatformException catch (error, stackTrace) {
      _logger.error(
        'Android markdown read failed',
        error: error,
        stackTrace: stackTrace,
      );
      throw MindMapStorageException('failed to read markdown', cause: error);
    }
  }

  @override
  Future<void> write(MindMapLocation location, String markdown) async {
    try {
      await _channel.invokeMethod<void>('writeMarkdown', {
        'fileToken': location.token,
        'markdown': markdown,
      });
    } on PlatformException catch (error, stackTrace) {
      _logger.error(
        'Android markdown write failed',
        error: error,
        stackTrace: stackTrace,
      );
      throw MindMapStorageException('failed to write markdown', cause: error);
    }
  }
}
