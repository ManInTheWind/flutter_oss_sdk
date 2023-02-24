//
//  OSSClientConfiguration.swift
//  flutter_oss_sdk
//
//  Created by kangkang on 2023/2/22.
//

import Foundation

struct FlutterOSSClientConfiguration {
    /// STS应用服务器地址
    var ossStsUrl: String

    /// 阿里云OSS服务
    var bucketEndPoint: String

    /// 设置是否开启DNS配置
    var httpDnsEnable: Bool

    /// 设置自定义user-agent
    var userAgentMark: String?

    /// 设置网络参数
    /// 连接超时，默认15秒
    var connectionTimeout: Int

    /// socket超时，默认15秒
    var socketTimeout: Int

    /// 最大并发请求书，默认5个
    var maxConcurrentRequest: Int

    /// 失败后最大重试次数，默认2次
    var maxErrorRetry: Int

    /// 是否开启开启日志
    var enableLog: Bool
    
    /**
     init(arguments:[String: Any]){
         bucketName = arguments["bucketName"] as? String ?? "";
         objectKey = arguments["objectKey"] as? String ?? "";
         uploadFilePath = arguments["uploadFilePath"] as? String ?? "";
         customDomain = arguments["customDomain"] as? String;
         callbackUrl = arguments["callbackUrl"] as? String;
         callbackHost = arguments["callbackHost"] as? String;
         callbackBodyType = arguments["callbackBodyType"] as? String;
         callbackBody = arguments["callbackBody"] as? String;
         callbackVars = arguments["callbackVars"] as? [String: String?];
     }
     */
    
    init(arguments:[String: Any]){
        ossStsUrl = arguments["ossStsUrl"] as? String ?? "";
        bucketEndPoint = arguments["bucketEndPoint"] as? String ?? "";
        httpDnsEnable = arguments["httpDnsEnable"] as? Bool ?? false;
        userAgentMark = arguments["userAgentMark"] as? String;
        connectionTimeout = arguments["connectionTimeout"] as? Int ?? 15 * 1000;
        socketTimeout = arguments["socketTimeout"] as? Int ?? 15 * 1000;
        maxConcurrentRequest = arguments["maxConcurrentRequest"] as? Int ?? 5;
        maxErrorRetry = arguments["maxErrorRetry"] as? Int ?? 3;
        enableLog = arguments["enableLog"] as? Bool ?? true;
    }
}
