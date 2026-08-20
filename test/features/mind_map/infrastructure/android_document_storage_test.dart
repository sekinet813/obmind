import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obmind/features/mind_map/domain/repositories/mind_map_storage.dart';
import 'package:obmind/features/mind_map/infrastructure/android_document_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel(AndroidDocumentStorage.channelName);
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  tearDown(() {
    messenger.setMockMethodCallHandler(channel, null);
  });

  test('pickFolder maps a tree URI to MindMapLocation', () async {
    messenger.setMockMethodCallHandler(channel, (call) async {
      expect(call.method, 'pickFolder');
      return 'content://tree/primary';
    });

    final storage = AndroidDocumentStorage(channel: channel);
    final folder = await storage.pickFolder();

    expect(folder?.token, 'content://tree/primary');
  });

  test('pickFolder returns null when the user cancels', () async {
    messenger.setMockMethodCallHandler(channel, (call) async => null);

    final storage = AndroidDocumentStorage(channel: channel);

    expect(await storage.pickFolder(), isNull);
  });

  test('create returns a file location without exposing SAF types', () async {
    messenger.setMockMethodCallHandler(channel, (call) async {
      expect(call.method, 'createMarkdown');
      expect(call.arguments['folderToken'], 'content://tree/primary');
      expect(call.arguments['displayName'], 'obmind-poc.md');
      expect(call.arguments['markdown'], contains('# Obmind'));
      return {
        'uri': 'content://tree/primary/document/obmind-poc.md',
        'displayName': 'obmind-poc.md',
      };
    });

    final storage = AndroidDocumentStorage(channel: channel);
    final file = await storage.create(
      const MindMapLocation('content://tree/primary'),
      'obmind-poc.md',
      markdown: '# Obmind\n',
    );

    expect(file.displayName, 'obmind-poc.md');
    expect(
      file.location.token,
      'content://tree/primary/document/obmind-poc.md',
    );
  });

  test('read and write go through the channel without SAF types', () async {
    messenger.setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'readMarkdown') {
        expect(call.arguments['fileToken'], 'content://doc/a.md');
        return '# Root\n';
      }
      if (call.method == 'writeMarkdown') {
        expect(call.arguments['fileToken'], 'content://doc/a.md');
        expect(call.arguments['markdown'], '# Edited\n');
        return null;
      }
      return null;
    });

    final storage = AndroidDocumentStorage(channel: channel);
    const location = MindMapLocation('content://doc/a.md');

    expect(await storage.read(location), '# Root\n');
    await storage.write(location, '# Edited\n');
  });

  test('list maps document URIs to MindMapFile', () async {
    messenger.setMockMethodCallHandler(channel, (call) async {
      expect(call.method, 'listMarkdown');
      expect(call.arguments['folderToken'], 'content://tree/primary');
      return [
        {'uri': 'content://doc/a.md', 'displayName': 'a.md'},
      ];
    });

    final storage = AndroidDocumentStorage(channel: channel);
    final files = await storage.list(
      const MindMapLocation('content://tree/primary'),
    );

    expect(files, hasLength(1));
    expect(files.single.displayName, 'a.md');
    expect(files.single.location.token, 'content://doc/a.md');
  });

  test('rename maps a new display name without exposing SAF types', () async {
    messenger.setMockMethodCallHandler(channel, (call) async {
      expect(call.method, 'renameMarkdown');
      expect(call.arguments['fileToken'], 'content://doc/a.md');
      expect(call.arguments['displayName'], 'b.md');
      return {'uri': 'content://doc/b.md', 'displayName': 'b.md'};
    });

    final storage = AndroidDocumentStorage(channel: channel);
    final renamed = await storage.rename(
      const MindMapLocation('content://doc/a.md'),
      'b.md',
    );

    expect(renamed.displayName, 'b.md');
    expect(renamed.location.token, 'content://doc/b.md');
  });

  test('delete goes through the channel without exposing SAF types', () async {
    messenger.setMockMethodCallHandler(channel, (call) async {
      expect(call.method, 'deleteMarkdown');
      expect(call.arguments['fileToken'], 'content://doc/a.md');
      return null;
    });

    final storage = AndroidDocumentStorage(channel: channel);
    await storage.delete(const MindMapLocation('content://doc/a.md'));
  });
}
