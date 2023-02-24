//
//  OSSUploadModel.swift
//  flutter_oss_sdk
//
//  Created by kangkang on 2023/2/22.
//

import Foundation

struct FlutterOSSUploadModel {
    var bucketName: String
    var objectKey: String
    var uploadFilePath: String

    /**
     * 自定义域名
     */
    var customDomain: String?

    var callbackUrl: String?
    var callbackHost: String?
    var callbackBodyType: String?
    var callbackBody: String?
    var callbackVars: [String: String?]?

    init(arguments: [String: Any])  {
        bucketName =  arguments["bucketName"] as? String ?? ""
        objectKey =  arguments["objectKey"] as? String ?? ""
        uploadFilePath =  arguments["uploadFilePath"] as? String ?? ""
        customDomain =  arguments["customDomain"] as? String
        callbackUrl =  arguments["callbackUrl"] as? String
        callbackHost =  arguments["callbackHost"] as? String
        callbackBodyType =  arguments["callbackBodyType"] as? String
        callbackBody =  arguments["callbackBody"] as? String
        callbackVars =  arguments["callbackVars"] as? [String: String?]
    }
}
