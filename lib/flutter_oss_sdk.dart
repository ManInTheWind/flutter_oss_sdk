import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_oss_sdk/oss_upload_reponse_model.dart';

import 'oss_client_configuration.dart';
import 'oss_upload_model.dart';

class FlutterOssSdk {
  final _methodChannel = const MethodChannel('flutter_oss_sdk');

  Future<String?> getPlatformVersion() async {
    final version =
        await _methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  Future<bool> initSdk(OSSClientConfiguration clientConfiguration) async {
    return await _methodChannel.invokeMethod<bool>(
          'initOSSClient',
          clientConfiguration.toJson(),
        ) ??
        false;
  }

  Future<String?> putObject(OSSUploadModel uploadModel) async {
    return await _methodChannel.invokeMethod<String>(
      'putObject',
      uploadModel.toJson(),
    );
  }

  ///异步上传单个或多个文件
  ///[onProgress] 返回一个Map,{'path':'文件路径','process':'进度'}
  ///[onSuccess] 返回一个上传成功的路径
  ///[onFailure] 返回失败的消息，String类型
  Future<void> putObjectAsync(
    List<OSSUploadModel> uploadModels, {
    AsyncValueSetter<OssUploadResponseProcessModel>? onProgress,
    AsyncValueSetter<OssUploadResponseSuccessModel>? onSuccess,
    AsyncValueSetter<OssUploadResponseFailureModel>? onFailure,
  }) async {
    _methodChannel.setMethodCallHandler((call) async {
      switch (call.method) {
        case "onProgress":
          // print('$runtimeType onProgress：${call.arguments}');
          await onProgress
              ?.call(OssUploadResponseProcessModel.fromJson(call.arguments));
          break;
        case "onSuccess":
          await onSuccess
              ?.call(OssUploadResponseSuccessModel.fromJson(call.arguments));
          break;
        case "onFailure":
          onFailure
              ?.call(OssUploadResponseFailureModel.fromJson(call.arguments));
          break;
        default:
          throw UnsupportedError('Unrecognized JSON message');
      }
    });
    return await _methodChannel.invokeMethod<void>(
      'putObjectAsync',
      uploadModels.map((e) => e.toJson()).toList(),
    );
  }
}
