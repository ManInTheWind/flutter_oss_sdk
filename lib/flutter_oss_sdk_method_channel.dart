import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_oss_sdk_platform_interface.dart';

/// An implementation of [FlutterOssSdkPlatform] that uses method channels.
class MethodChannelFlutterOssSdk extends FlutterOssSdkPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_oss_sdk');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}