part of flutter_oss_sdk;

@immutable
class OSSUploadModel {
  ///bucket名称
  final String bucketName;

  ///bucket存放路径
  final String objectKey;

  ///需要上传文件的本地路径
  final String uploadFilePath;

  ///自定义域名,可用于上传成功时自动拼接网络路径
  final String? customDomain;

  ///回调地址
  final String? callbackUrl;

  ///回调域名
  final String? callbackHost;

  ///回调的POST请求体数据类型,如 "application/json"
  final String? callbackBodyType;

  ///回调的POST请求体数据
  final String? callbackBody;

  ///回调的POST请求体参数
  final Map<String, String?>? callbackVars;

  ///content-type
  final String? contentType;

  OSSUploadModel({
    required this.bucketName,
    required this.objectKey,
    required this.uploadFilePath,
    this.customDomain,
    this.callbackUrl,
    this.callbackHost,
    this.callbackBodyType,
    this.callbackBody,
    this.callbackVars,
    this.contentType,
  })  : assert(bucketName.isNotEmpty, 'Bucket不能为空'),
        assert(objectKey.isNotEmpty, 'ObjectKey不能为空'),
        assert(uploadFilePath.isNotEmpty, '上传路径不能为空');

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'bucketName': bucketName,
      'objectKey': objectKey,
      'uploadFilePath': uploadFilePath,
      'customDomain': customDomain,
      'callbackUrl': callbackUrl,
      'callbackHost': callbackHost,
      'callbackBodyType': callbackBodyType,
      'callbackBody': callbackBody,
      'callbackVars': callbackVars,
      'contentType': contentType,
    }..removeWhere((key, value) => value == null);
  }
}
