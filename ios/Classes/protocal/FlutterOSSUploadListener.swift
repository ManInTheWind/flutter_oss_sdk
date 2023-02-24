//
//  OSSUploadFileListener.swift
//  flutter_oss_sdk
//
//  Created by kangkang on 2023/2/22.
//

import Foundation

protocol FlutterOSSUploadListener: AnyObject {
    func uploadProgress(processModel: FlutterOssUploadResponseProcessModel) -> Void

    func uploadSuccess(successModel: FlutterOssUploadResponseSuccessModel) -> Void

    func uploadFailed(failureModel: FlutterOssUploadResponseFailureModel) -> Void
}
