import 'package:flutter_oss_sdk/flutter_oss_sdk.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterOssSdkPlatform
    with MockPlatformInterfaceMixin
    implements FlutterOssSdkPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FlutterOssSdkPlatform initialPlatform = FlutterOssSdkPlatform.instance;

  test('$MethodChannelFlutterOssSdk is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterOssSdk>());
  });

  test('getPlatformVersion', () async {
    MockFlutterOssSdkPlatform fakePlatform = MockFlutterOssSdkPlatform();
    FlutterOssSdkPlatform.instance = fakePlatform;

    expect(await FlutterOSSClient.getPlatformVersion(), '42');
  });
}
