import AliyunOSSiOS
import Flutter
import UIKit

public class FlutterOssSdkPlugin: NSObject, FlutterPlugin {
    private static var FLUTTER_ERROR_CODE: String = "-1"
    
    private static var FLUTTER_METHOD_PROCESS: String = "onProgress"
    
    private static var FLUTTER_METHOD_SUCCESS: String = "onSuccess"
    
    private static var FLUTTER_METHOD_FAILURE: String = "onFailure"
    
    private var _ossClient: OSSClient?
    
    private var OSS_END_POINT: String?
    
    private var OSS_STS_AUTH_URL: String?
    
    private var methodChannel: FlutterMethodChannel?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_oss_sdk", binaryMessenger: registrar.messenger())
        let instance = FlutterOssSdkPlugin()
        instance.methodChannel = channel
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)
            break;
        case "initOSSClient":
            initSdk(call.arguments, result)
            break;
        case "putObject":
            pubObject(call.arguments, result)
            break;
        case "putObjectAsync":
            putObjectAsync(call.arguments, result)
            break;
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    public func initSdk(_ arguments: Any?, _ result: @escaping FlutterResult) {
        guard let configMap = arguments as? [String: Any] else {
            result(FlutterError(code: FlutterOssSdkPlugin.FLUTTER_ERROR_CODE, message: "解析arguments遇到错误:参数不正确", details: nil))
            return
        }
        
        let flutterOssConfiguration = FlutterOSSClientConfiguration(arguments: configMap)
        
        OSS_END_POINT = flutterOssConfiguration.bucketEndPoint
        
        OSS_STS_AUTH_URL = flutterOssConfiguration.ossStsUrl

        let credentialProvider = OSSAuthCredentialProvider(authServerUrl: OSS_STS_AUTH_URL!)
        
        let ossClientConfiguration = OSSClientConfiguration()
        
        ossClientConfiguration.maxRetryCount = UInt32(flutterOssConfiguration.maxErrorRetry)
        
        ossClientConfiguration.timeoutIntervalForRequest = 30
        
        ossClientConfiguration.timeoutIntervalForResource = TimeInterval(flutterOssConfiguration.connectionTimeout)
        
        if flutterOssConfiguration.enableLog {
            OSSLog.enable()
        }

        _ossClient = OSSClient(endpoint: OSS_END_POINT!, credentialProvider: credentialProvider, clientConfiguration: ossClientConfiguration)
        
        result(true)
    }
    
    //MARK: - 同步上传单个文件
    
    public func pubObject(_ arguments: Any?, _ result: @escaping FlutterResult) {
        guard let uploadModelMap = arguments as? [String: Any] else {
            result(FlutterError(code: FlutterOssSdkPlugin.FLUTTER_ERROR_CODE, message: "解析arguments遇到错误:参数不正确", details: nil))
            return
        }
        
        let uploadModel = FlutterOSSUploadModel(arguments: uploadModelMap)
        
        let putRequest = OSSPutObjectRequest()
        
        putRequest.bucketName = uploadModel.bucketName
        
        putRequest.objectKey = uploadModel.objectKey
        
        if let contentType = uploadModel.contentType{
            putRequest.contentType = contentType
        }
        
        putRequest.uploadingFileURL = URL(fileURLWithPath: uploadModel.uploadFilePath)
        
        let putTask = _ossClient?.putObject(putRequest)
        
        if putTask == nil {
            result(FlutterError(code: FlutterOssSdkPlugin.FLUTTER_ERROR_CODE, message: "请求失败，未初始化客户端", details: nil))
            return
        }
        
        putTask!.continue ({ task -> Any? in
            print("contentType:\(putRequest.contentType)")
            if task.error != nil {
                let errors = task.error! as NSError
               
                let flutterError = FlutterError(code: String(errors.code), message: task.error?.localizedDescription.description, details: task.error.debugDescription)
                result(flutterError)
            } else {
                let domain: String
                if uploadModel.customDomain != nil {
                    domain = uploadModel.customDomain!
                } else {
                    domain = "\(uploadModel.bucketName).\(self.OSS_END_POINT!)"
                }
                
                let ossFileUrl = "https://\(domain)/\(uploadModel.objectKey)"
                result(ossFileUrl)
            }
            return nil
        }).waitUntilFinished()
       
    }
    
    //MARK: - 异步上传单个/多个文件
    
    public func putObjectAsync(_ arguments: Any?, _ result: @escaping FlutterResult) {
        if _ossClient == nil {
            result(FlutterError(code: FlutterOssSdkPlugin.FLUTTER_ERROR_CODE, message: "请求失败，未初始化客户端", details: nil))
            return
        }
        
        guard let argumentsList = arguments as? [[String: Any]] else {
            result(FlutterError(code: FlutterOssSdkPlugin.FLUTTER_ERROR_CODE, message: "解析arguments遇到错误:参数不正确", details: nil))
            return
        }
        
        var uploadModelList = [FlutterOSSUploadModel]()
        
        for uploadModelMap in argumentsList {
            let uploadModel = FlutterOSSUploadModel(arguments: uploadModelMap)
            
            uploadModelList.append(uploadModel)
        }
        
        if uploadModelList.isEmpty {
            result(FlutterError(code: FlutterOssSdkPlugin.FLUTTER_ERROR_CODE, message: "上传数据为空", details: nil))
            return
        }
        
        DispatchQueue(label: "com.fluttercandies.uploadQueue",attributes: .concurrent)
            .async {
                self.onPutObjectAsync(uploadModelList)
            }
        
        
        
//        let dispatchGroup = DispatchGroup()
//
//        let dispatchQueue = DispatchQueue(label: "com.fluttercandies.uploadQueue",attributes: .concurrent)
//
//        for uploadModel in uploadModelList {
//            dispatchGroup.enter()
//            dispatchQueue.async {
//                self.onPutObjectAsync(uploadModel)
//                dispatchGroup.leave()
//            }
//
//        }
//
//        dispatchGroup.wait()
//
//        print("All upload tasks are completed.")
        
        result(true)
    }
    
    private func onPutObjectAsync(_ uploadModel: FlutterOSSUploadModel) {
        let putRequest = OSSPutObjectRequest()
        
        putRequest.bucketName = uploadModel.bucketName
        
        putRequest.objectKey = uploadModel.objectKey
        
        putRequest.uploadingFileURL = URL(fileURLWithPath: uploadModel.uploadFilePath)
        
        if let contentType = uploadModel.contentType{
            putRequest.contentType = contentType
        }
        
        if let callbackUrl = uploadModel.callbackUrl{
            
            putRequest.callbackParam = ["callbackUrl": callbackUrl]
 
            if let callbackBody = uploadModel.callbackBody {
                putRequest.callbackParam.updateValue(callbackBody, forKey: "callbackBody")
                print("callbackParam:\(putRequest.callbackParam)")
            }
            
            if let callbackBodyType = uploadModel.callbackBodyType {
                putRequest.callbackParam.updateValue(callbackBodyType, forKey: "callbackBodyType")
                print("callbackBodyType:\(putRequest.callbackParam)")
            }

            if let callbackVars =  uploadModel.callbackVars{
                putRequest.callbackVar = callbackVars as [AnyHashable : Any]
                print("callbackParam:\(putRequest.callbackVar)")
            }
        }
        
        
        
        
        putRequest.uploadProgress = { bytesSent, totalByteSent, totalBytesExpectedToSend in
            // 指定当前上传长度、当前已经上传总长度、待上传的总长度。
            print("bytesSent: \(bytesSent),totalByteSent: \(totalByteSent),totalBytesExpectedToSend: \(totalBytesExpectedToSend)")
            let processModel = FlutterOssUploadResponseProcessModel(
                path: uploadModel.uploadFilePath,
                currentSize: Int(totalByteSent),
                totalSize: Int(totalBytesExpectedToSend)
            )
            self.methodChannel?.invokeMethod(FlutterOssSdkPlugin.FLUTTER_METHOD_PROCESS, arguments: processModel.toJson())
        }
        
       
        
        let putTask = _ossClient!.putObject(putRequest)
        
        putTask.continue ({ task -> Any? in
            if task.error != nil {
                let errors = task.error! as NSError
               
                let failureModel = FlutterOssUploadResponseFailureModel(
                    path: uploadModel.uploadFilePath,
                    errorCode: String(errors.code),
                    errorMessage: task.error?.localizedDescription.description
                )

                self.methodChannel?.invokeMethod(FlutterOssSdkPlugin.FLUTTER_METHOD_FAILURE, arguments: failureModel.toJson())
                
            } else {
                let domain: String
                if uploadModel.customDomain != nil {
                    domain = uploadModel.customDomain!
                } else {
                    domain = "\(uploadModel.bucketName).\(self.OSS_END_POINT!)"
                }
                
                let ossFileUrl = "https://\(domain)/\(uploadModel.objectKey)"
                
                let successModel = FlutterOssUploadResponseSuccessModel(
                    path: uploadModel.uploadFilePath,
                    fileUrl: ossFileUrl,
                    serverCallbackReturnJson: task.result?.serverReturnJsonString
                )

                self.methodChannel?.invokeMethod(FlutterOssSdkPlugin.FLUTTER_METHOD_SUCCESS, arguments: successModel.toJson())
            }
            return nil
        })
        .waitUntilFinished()
    }
    
    private func onPutObjectAsync(_ dataList: [FlutterOSSUploadModel]) {
        var uploadModelList = [FlutterOSSUploadModel]()
        
        uploadModelList.append(contentsOf: dataList)
        
        guard let uploadModel = uploadModelList.first else{
            let failureModel = FlutterOssUploadResponseFailureModel(
                path: "",
                errorCode: FlutterOssSdkPlugin.FLUTTER_ERROR_CODE,
                errorMessage: "上传数据为空"
            )
            self.methodChannel?.invokeMethod(FlutterOssSdkPlugin.FLUTTER_METHOD_FAILURE, arguments: failureModel.toJson())
            return;
        }
        
        let putRequest = OSSPutObjectRequest()
        
        putRequest.bucketName = uploadModel.bucketName
        
        putRequest.objectKey = uploadModel.objectKey
        
        putRequest.uploadingFileURL = URL(fileURLWithPath: uploadModel.uploadFilePath)
        
        if let callbackUrl = uploadModel.callbackUrl{
            print("callbackUrl:\(callbackUrl)")
            putRequest.callbackParam = ["callbackUrl": callbackUrl]
 
            if let callbackBody = uploadModel.callbackBody {
                putRequest.callbackParam.updateValue(callbackBody, forKey: "callbackBody")
                print("callbackParam:\(putRequest.callbackParam)")
            }
            
            if let callbackBodyType = uploadModel.callbackBodyType {
                putRequest.callbackParam.updateValue(callbackBodyType, forKey: "callbackBodyType")
                print("callbackBodyType:\(putRequest.callbackParam)")
            }

            if let callbackVars =  uploadModel.callbackVars{
                putRequest.callbackVar = callbackVars as [AnyHashable : Any]
                print("callbackParam:\(putRequest.callbackVar)")
            }
        }
        
    
        
        putRequest.uploadProgress = { bytesSent, totalByteSent, totalBytesExpectedToSend in
            // 指定当前上传长度、当前已经上传总长度、待上传的总长度。
            print("bytesSent: \(bytesSent),totalByteSent: \(totalByteSent),totalBytesExpectedToSend: \(totalBytesExpectedToSend)")
            let processModel = FlutterOssUploadResponseProcessModel(
                path: uploadModel.uploadFilePath,
                currentSize: Int(totalByteSent),
                totalSize: Int(totalBytesExpectedToSend)
            )
            self.methodChannel?.invokeMethod(FlutterOssSdkPlugin.FLUTTER_METHOD_PROCESS, arguments: processModel.toJson())
        }
        
        let putTask = _ossClient!.putObject(putRequest)
        
        putTask.continue ({ task -> Any? in
            if task.error != nil {
                let errors = task.error! as NSError
               
                let failureModel = FlutterOssUploadResponseFailureModel(
                    path: uploadModel.uploadFilePath,
                    errorCode: String(errors.code),
                    errorMessage: task.error?.localizedDescription.description
                )

                self.methodChannel?.invokeMethod(FlutterOssSdkPlugin.FLUTTER_METHOD_FAILURE, arguments: failureModel.toJson())
                
            } else {
                let domain: String
                if uploadModel.customDomain != nil {
                    domain = uploadModel.customDomain!
                } else {
                    domain = "\(uploadModel.bucketName).\(self.OSS_END_POINT!)"
                }
                
                let ossFileUrl = "https://\(domain)/\(uploadModel.objectKey)"
                
                let successModel = FlutterOssUploadResponseSuccessModel(
                    path: uploadModel.uploadFilePath,
                    fileUrl: ossFileUrl,
                    serverCallbackReturnJson: task.result?.serverReturnJsonString
                )

                self.methodChannel?.invokeMethod(FlutterOssSdkPlugin.FLUTTER_METHOD_SUCCESS, arguments: successModel.toJson())
                
                uploadModelList.removeFirst()
                
                if !uploadModelList.isEmpty {
                    self.onPutObjectAsync(uploadModelList)
                }
            }
            return nil
        }).waitUntilFinished()
    }
}
