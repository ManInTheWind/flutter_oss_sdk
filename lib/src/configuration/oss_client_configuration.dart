part of flutter_oss_sdk;

@immutable
class OSSClientConfiguration {
  ///STS应用服务器地址
  final String ossStsUrl;

  ///阿里云OSS服务
  final String bucketEndPoint;

  ///设置是否开启DNS配置
  final bool httpDnsEnable;

  ///设置自定义user-agent
  final String? userAgentMark;

  ///设置网络参数
  ///连接超时，默认15秒
  final int connectionTimeout;

  ///socket超时，默认15秒
  final int socketTimeout;

  ///最大并发请求书，默认5个
  final int maxConcurrentRequest;

  ///失败后最大重试次数，默认2次
  final int maxErrorRetry;

  ///是否开启开启日志
  final bool enableLog;

  const OSSClientConfiguration({
    required this.ossStsUrl,
    required this.bucketEndPoint,
    this.httpDnsEnable = false,
    this.userAgentMark,
    this.connectionTimeout = 15 * 1000,
    this.socketTimeout = 15 * 1000,
    this.maxConcurrentRequest = 5,
    this.maxErrorRetry = 2,
    this.enableLog = kDebugMode,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'ossStsUrl': ossStsUrl,
      'bucketEndPoint': bucketEndPoint,
      'httpDnsEnable': httpDnsEnable,
      'userAgentMark': userAgentMark,
      'connectionTimeout': connectionTimeout,
      'socketTimeout': socketTimeout,
      'maxConcurrentRequest': maxConcurrentRequest,
      'maxErrorRetry': maxErrorRetry,
      'enableLog': enableLog,
    }..removeWhere((key, value) => value == null);
  }
}
