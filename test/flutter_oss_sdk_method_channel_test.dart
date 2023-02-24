import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_oss_sdk/flutter_oss_sdk_method_channel.dart';

void main() {
  MethodChannelFlutterOssSdk platform = MethodChannelFlutterOssSdk();
  const MethodChannel channel = MethodChannel('flutter_oss_sdk');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
