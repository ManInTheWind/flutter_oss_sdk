part of flutter_oss_sdk;

abstract class OssUploadResponseModel {
  final String path;

  const OssUploadResponseModel(this.path);
}

class OssUploadResponseProcessModel extends OssUploadResponseModel {
  final int currentSize;
  final int totalSize;

  OssUploadResponseProcessModel.fromJson(Map<Object?, Object?> json)
      : currentSize = json['currentSize'] as int,
        totalSize = json['totalSize'] as int,
        super(json['path'] as String);

  @override
  String toString() {
    return 'OssUploadResponseProcessModel{path:$path,currentSize: $currentSize, totalSize: $totalSize}';
  }
}

class OssUploadResponseSuccessModel extends OssUploadResponseModel {
  /// 上传成功的路径
  final String fileUrl;

  /// 只有设置了ServerCallback，该值才有数据。
  final String? serverCallbackReturnJson;

  OssUploadResponseSuccessModel.fromJson(Map<Object?, Object?> json)
      : fileUrl = json['fileUrl'] as String,
        serverCallbackReturnJson = json['serverCallbackReturnJson'] as String?,
        super(json['path'] as String);

  @override
  String toString() {
    return 'OssUploadResponseSuccessModel{path:$path,fileUrl: $fileUrl, serverCallbackReturnJson: $serverCallbackReturnJson}';
  }
}

class OssUploadResponseFailureModel extends OssUploadResponseModel {
  final String errorCode;
  final String? requestId;
  final String? hostId;
  final String? errorMessage;

  OssUploadResponseFailureModel.fromJson(Map<Object?, Object?> json)
      : errorCode = json['errorCode'] as String,
        requestId = json['requestId'] as String?,
        hostId = json['hostId'] as String?,
        errorMessage = json['errorMessage'] as String?,
        super(json['path'] as String);

  @override
  String toString() {
    return 'OssUploadResponseFailureModel{path:$path,errorCode: $errorCode, requestId: $requestId, hostId: $hostId, errorMessage: $errorMessage}';
  }
}
