part of flutter_oss_sdk;

abstract class FlutterOssSdkPlatform extends PlatformInterface {
  /// Constructs a FlutterOssSdkPlatform.
  FlutterOssSdkPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterOssSdkPlatform _instance = MethodChannelFlutterOssSdk();

  /// The default instance of [FlutterOssSdkPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterOssSdk].
  static FlutterOssSdkPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterOssSdkPlatform] when
  /// they register themselves.
  static set instance(FlutterOssSdkPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
