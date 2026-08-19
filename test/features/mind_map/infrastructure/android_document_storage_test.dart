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
}
