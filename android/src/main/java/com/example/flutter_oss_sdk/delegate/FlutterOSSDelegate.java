package com.example.flutter_oss_sdk.delegate;

import android.content.Context;

import com.example.flutter_oss_sdk.model.FlutterOSSClientConfiguration;
import com.example.flutter_oss_sdk.model.FlutterOSSUploadModel;

import java.util.List;

import io.flutter.plugin.common.MethodChannel;

public interface FlutterOSSDelegate {

    void init(Context context, FlutterOSSClientConfiguration config, MethodChannel.Result result);
    /**
     * 同步上传单个文件
     *
     * @param uploadModel 上传参数
     * @param result    返回结果
     */
    void putObject(FlutterOSSUploadModel uploadModel, MethodChannel.Result result);
    /**
     * 异步上传单个或多个文件
     *
     * @param uploadModelList 上传参数数组
     * @param listener 上传回调监听
     */
    void pubObjectAsync(List<FlutterOSSUploadModel> uploadModelList, FlutterOSSUploadListener listener);
}
