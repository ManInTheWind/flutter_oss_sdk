package com.example.flutter_oss_sdk.delegate;

import com.example.flutter_oss_sdk.model.FlutterOssUploadResponseFailureModel;
import com.example.flutter_oss_sdk.model.FlutterOssUploadResponseProcessModel;
import com.example.flutter_oss_sdk.model.FlutterOssUploadResponseSuccessModel;

public interface FlutterOSSUploadListener {
    void uploadProgress(FlutterOssUploadResponseProcessModel processModel);

    void uploadSuccess(FlutterOssUploadResponseSuccessModel successModel);

    void uploadFailed(FlutterOssUploadResponseFailureModel failureModel);
}
