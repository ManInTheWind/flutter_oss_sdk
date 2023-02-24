//
//  OssUploadResponseModel.swift
//  flutter_oss_sdk
//
//  Created by kangkang on 2023/2/22.
//

import Foundation

class FlutterOssUploadResponseModel {
    var path: String

    init(path: String) {
        self.path = path
    }
}

class FlutterOssUploadResponseProcessModel: FlutterOssUploadResponseModel {
    var currentSize: Int
    var totalSize: Int

    init(path: String, currentSize: Int, totalSize: Int) {
        self.currentSize = currentSize
        self.totalSize = totalSize
        super.init(path: path)
    }

    func toJson() -> [String: Any?] {
        return [
            "path": path,
            "currentSize": currentSize,
            "totalSize": totalSize,
        ]
    }
}

class FlutterOssUploadResponseSuccessModel: FlutterOssUploadResponseModel {
    var fileUrl: String

    /// 只有设置了ServerCallback，该值才有数据。
    var serverCallbackReturnJson: String?

    init(path: String, fileUrl: String, serverCallbackReturnJson: String? = nil) {
        self.fileUrl = fileUrl
        self.serverCallbackReturnJson = serverCallbackReturnJson
        super.init(path: path)
    }

    func toJson() -> [String: Any?] {
        return [
            "path": path,
            "fileUrl": fileUrl,
            "serverCallbackReturnJson": serverCallbackReturnJson,
        ]
    }
}

class FlutterOssUploadResponseFailureModel: FlutterOssUploadResponseModel {
    var errorCode: String
    var requestId: String?
    var hostId: String?
    var errorMessage: String?

    init(path: String, errorCode: String, requestId: String? = nil, hostId: String? = nil, errorMessage: String? = nil) {
        self.errorCode = errorCode
        self.requestId = requestId
        self.hostId = hostId
        self.errorMessage = errorMessage
        super.init(path: path)
    }

    func toJson() -> [String: Any?] {
        return [
            "path": path,
            "errorCode": errorCode,
            "requestId": requestId,
            "hostId": hostId,
            "errorMessage": errorMessage,
        ]
    }
}
