//
//  FlutterOSSClient.swift
//  flutter_oss_sdk
//
//  Created by kangkang on 2023/2/22.
//

import Foundation
import AliyunOSSiOS


final class FlutterOSSClient {
    
    
//    private var _ossClient:OSSClient?
//
//   
//
//    public func initSdk(configuration: FlutterOSSClientConfiguration,result:@escaping FlutterResult) -> Void {
//        let flutterOssConfiguration = FlutterOSSClientConfiguration.init(arguments: configMap)
//
//
//        let credentialProvider = OSSAuthCredentialProvider(authServerUrl: flutterOssConfiguration.ossStsUrl)
//
//
//       let ossClientConfiguration =  OSSClientConfiguration()
//
//
//        ossClientConfiguration.maxRetryCount = UInt32(flutterOssConfiguration.maxErrorRetry)
//
//        ossClientConfiguration.timeoutIntervalForRequest = 30
//
//        ossClientConfiguration.timeoutIntervalForResource = TimeInterval(flutterOssConfiguration.connectionTimeout)
//
//        if(flutterOssConfiguration.enableLog){
//            OSSLog.enable()
//        }
//
//        _ossClient = OSSClient(endpoint: flutterOssConfiguration.bucketEndPoint, credentialProvider: credentialProvider,clientConfiguration: ossClientConfiguration)
//
//
//        result(true)
//    }
//
//    public func putObject( uploadModel:FlutterOSSUploadModel, result: @escaping FlutterResult) -> Void {
//
//        let putRequest = OSSPutObjectRequest()
//
//        putRequest.bucketName = uploadModel.bucketName;
//
//        putRequest.objectKey = uploadModel.objectKey;
//
//        putRequest.uploadingFileURL = URL(fileURLWithPath: uploadModel.uploadFilePath)
//
//        let putTask: OSSTask =  _ossClient?.putObject(putRequest)
//
//        putTask.continue({ (task) -> Any? in
//
//            if task.error {
//
//                result(false)
//            }
//
//            return nil
//        }).waitUntilFinished()
//
//    }
    
    
}
