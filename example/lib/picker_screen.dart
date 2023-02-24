import 'dart:convert';
import 'dart:core';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_oss_sdk/flutter_oss_sdk.dart';
import 'package:flutter_oss_sdk/oss_client_configuration.dart';
import 'package:flutter_oss_sdk/oss_upload_model.dart';
import 'package:flutter_oss_sdk/oss_upload_reponse_model.dart';
import 'package:nanoid/nanoid.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class PickerScreen extends StatefulWidget {
  const PickerScreen({super.key});

  @override
  State<PickerScreen> createState() => _PickerScreenState();
}

class _PickerScreenState extends State<PickerScreen> {
  final FlutterOssSdk _ossSdk = FlutterOssSdk();

  List<AssetEntity> selectedAssets = <AssetEntity>[];
  static const String BUCKET_NAME = "imagefilefreeyo";
  static const String FOLDER_NAME = "test/";
  static const String AVATAR_FOLDER_NAME = "avatar/";
  static const String POST_FOLDER_NAME = "post/";
  static const String TOPIC_FOLDER_NAME = "topic/";

  List<Map<String, dynamic>>? _uploadProcess;

  final List<String> _uploadSuccessPathList = <String>[];

  bool _isUploading = false;

  bool get isUploading => _isUploading;

  set isUploading(bool v) {
    if (mounted) {
      setState(() {
        _isUploading = v;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _callPicker() async {
    final List<AssetEntity>? result = await AssetPicker.pickAssets(
      context,
      pickerConfig: AssetPickerConfig(
        selectedAssets: selectedAssets,
        pageSize: 60,
        gridCount: 3,
      ),
    );

    if (result != null) {
      if (mounted) {
        setState(() {
          selectedAssets = result;
          _uploadProcess = List.generate(selectedAssets.length, (index) {
            return {
              'path': null,
              'process': 0.0,
            };
          });
        });
      }
    }
  }

  void showMsg(String title, String? content) {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      // false = user must tap button, true = tap outside dialog
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(content ?? ''),
          actions: <Widget>[
            TextButton(
              child: const Text('好的'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Dismiss alert dialog
              },
            ),
          ],
        );
      },
    );
  }

  void initSdk() async {
    isUploading = true;
    const config = OSSClientConfiguration(
      ossStsUrl: 'http://47.107.37.194:7080/app-api/app-common/upload-access',
      bucketEndPoint: 'oss-cn-shenzhen.aliyuncs.com',
      enableLog: true,
    );
    try {
      bool success = await _ossSdk.initSdk(config);
      showMsg('初始化结果', '是否成功：$success');
    } on PlatformException catch (e) {
      print(e);

      showMsg('失败',
          'code:${e.code},message:${e.message},details:${e.details},stackTrace:${e.stacktrace}');
    } catch (e, s) {
      print(e);
      print(s);
      showMsg('失败', 'code:$e,stackTrace:${s}');
    } finally {
      isUploading = false;
    }
  }

  void uploadSingle() async {
    if (selectedAssets.isEmpty) return;
    isUploading = true;
    final AssetEntity entity = selectedAssets.first;
    final filename = await entity.titleAsync;
    final file = await entity.file;
    if (file == null) {
      showMsg(
        '上传失败',
        'Unable to obtain file of the entity ${entity.id}.',
      );
      return;
    }
    final String objectKey = FOLDER_NAME + filename;
    final OSSUploadModel uploadModel = OSSUploadModel(
      bucketName: BUCKET_NAME,
      objectKey: objectKey,
      uploadFilePath: file.path,
    );
    try {
      final String? fileUrl = await _ossSdk.putObject(uploadModel);
      showMsg('上传成功', 'fileUrl: $fileUrl.');
      if (fileUrl != null) {
        setState(() {
          _uploadSuccessPathList.add(fileUrl);
        });
      }
    } on PlatformException catch (e) {
      print(e);
      showMsg('PlatformException 失败',
          'code:${e.code},message:${e.message},details:${e.details},stackTrace:${e.stacktrace}');
    } catch (e, s) {
      print(e);
      print(s);
      showMsg('失败', 'code:$e,stackTrace:${s}');
    } finally {
      isUploading = false;
    }
  }

  void uploadMultiSync() async {
    if (selectedAssets.isEmpty) return;
    isUploading = true;

    List<OSSUploadModel> uploadModels = <OSSUploadModel>[];
    await Future.forEach(selectedAssets, (entity) async {
      // final AssetEntity entity = selectedAssets.first;
      final index =
          selectedAssets.indexWhere((element) => element.id == entity.id);
      final filename = await entity.titleAsync;
      final file = await entity.file;
      if (file == null) {
        showMsg(
          '上传失败',
          'Unable to obtain file of the entity ${entity.id}.',
        );
        return;
      }
      final String objectKey = FOLDER_NAME + filename;
      final OSSUploadModel uploadModel = OSSUploadModel(
        bucketName: BUCKET_NAME,
        objectKey: objectKey,
        uploadFilePath: file.path,
      );
      uploadModels.add(uploadModel);
      _uploadProcess ??= [];
      _uploadProcess?.elementAt(index)['path'] = file.path;
    });
    try {
      await _ossSdk.putObjectAsync(
        uploadModels,
        onProgress: (OssUploadResponseProcessModel processModel) async {
          final process = processModel.currentSize / processModel.totalSize;
          print('$runtimeType onProgress：${processModel.path},上传进度：$process');
          setState(() {
            _uploadProcess?.forEach((element) {
              if (element['path'] == processModel.path) {
                element['process'] = process;
              }
            });
          });
        },
        onSuccess: (OssUploadResponseSuccessModel successModel) async {
          print('onSuccess：$successModel');
          // showMsg('上传成功', 'ETag: $eTag.');
          setState(() {
            _uploadSuccessPathList.add(successModel.fileUrl);
          });
          if (_uploadSuccessPathList.length == uploadModels.length) {
            isUploading = false;
          }
        },
        onFailure: (OssUploadResponseFailureModel failureModel) async {
          showMsg('失败', '错误：$failureModel');
        },
      );
    } on PlatformException catch (e) {
      print(e);
      showMsg('PlatformException 失败',
          'code:${e.code},message:${e.message},details:${e.details},stackTrace:${e.stacktrace}');
    } catch (e, s) {
      print(e);
      print(s);
      showMsg('失败', 'code:$e,stackTrace:${s}');
    } finally {
      isUploading = false;
    }
  }

  void uploadAvatarWithCallbackSync() async {
    if (selectedAssets.isEmpty) return;
    isUploading = true;

    List<OSSUploadModel> uploadModels = <OSSUploadModel>[];
    await Future.forEach(selectedAssets, (entity) async {
      // final AssetEntity entity = selectedAssets.first;
      final index =
          selectedAssets.indexWhere((element) => element.id == entity.id);
      final filename = await entity.titleAsync;
      final file = await entity.file;
      if (file == null) {
        showMsg(
          '上传失败',
          'Unable to obtain file of the entity ${entity.id}.',
        );
        return;
      }
      final String objectKey = AVATAR_FOLDER_NAME + filename;
      final OSSUploadModel uploadModel = OSSUploadModel(
        bucketName: BUCKET_NAME,
        objectKey: objectKey,
        uploadFilePath: file.path,
        customDomain: 'pic.jalagar.com',
        callbackUrl: 'http://47.107.37.194:7080/app-api/callback/avatar',
        callbackBodyType: ContentType.json.mimeType,
        callbackBody: "{\"object\":\$\{object},"
            "\"user_id\":\$\{x:user_id},"
            "\"image_width\":\$\{x:image_width},"
            "\"image_height\":\$\{x:image_height},"
            "\"imageInfo_format\":\$\{imageInfo.format},"
            "\"id\":\$\{etag},"
            "\"size\":\$\{size},"
            "\"tag\":\$\{x:tag},"
            "\"image_index\":\$\{x:image_index},"
            "\"image_info_length\":\$\{x:image_info_length}}",
        callbackVars: <String, String>{
          'x:user_id': '3432360930586624',
          'x:image_width': entity.width.toString(),
          'x:image_height': entity.height.toString(),
          'x:tag': nanoid(),
          'x:image_index': "0",
          'x:image_info_length': "1",
        },
      );
      uploadModels.add(uploadModel);
      _uploadProcess ??= [];
      _uploadProcess?.elementAt(index)['path'] = file.path;
    });
    try {
      await _ossSdk.putObjectAsync(
        uploadModels,
        onProgress: (OssUploadResponseProcessModel processModel) async {
          final process = processModel.currentSize / processModel.totalSize;
          print('$runtimeType onProgress：${processModel.path},上传进度：$process');
          setState(() {
            _uploadProcess?.forEach((element) {
              if (element['path'] == processModel.path) {
                element['process'] = process;
              }
            });
          });
        },
        onSuccess: (OssUploadResponseSuccessModel successModel) async {
          print('onSuccess：$successModel');
          // showMsg('上传成功', 'ETag: $eTag.');
          setState(() {
            _uploadSuccessPathList.add(successModel.fileUrl);
          });
          if (_uploadSuccessPathList.length == uploadModels.length) {
            isUploading = false;
          }
        },
        onFailure: (OssUploadResponseFailureModel failureModel) async {
          showMsg('失败', '错误：${failureModel.errorMessage}');
        },
      );
    } on PlatformException catch (e) {
      print(e);
      showMsg('PlatformException 失败',
          'code:${e.code},message:${e.message},details:${e.details},stackTrace:${e.stacktrace}');
    } catch (e, s) {
      print(e);
      print(s);
      showMsg('失败', 'code:$e,stackTrace:${s}');
    } finally {
      isUploading = false;
    }
  }

  void uploadPostWithCallbackSync() async {
    if (selectedAssets.isEmpty) return;
    isUploading = true;

    List<OSSUploadModel> uploadModels = <OSSUploadModel>[];
    await Future.forEach(selectedAssets, (entity) async {
      // final AssetEntity entity = selectedAssets.first;
      final index =
          selectedAssets.indexWhere((element) => element.id == entity.id);
      final filename = await entity.titleAsync;
      final file = await entity.file;
      if (file == null) {
        showMsg(
          '上传失败',
          'Unable to obtain file of the entity ${entity.id}.',
        );
        return;
      }
      final String objectKey = POST_FOLDER_NAME + filename;
      final OSSUploadModel uploadModel = OSSUploadModel(
        bucketName: BUCKET_NAME,
        objectKey: objectKey,
        uploadFilePath: file.path,
        customDomain: 'pic.jalagar.com',
        callbackUrl: 'http://47.107.37.194:7080/app-api/callback/post',
        callbackBodyType: ContentType.json.mimeType,
        callbackBody: "{\"object\":\$\{object},"
            "\"user_id\":\$\{x:user_id},"
            "\"description\":\$\{x:description},"
            "\"topic_info\":\$\{x:topic_info},"
            "\"mention_info\":\$\{x:mention_info},"
            "\"location_info\":\$\{x:location_info},"
            "\"image_width\":\$\{x:image_width},"
            "\"image_height\":\$\{x:image_height},"
            "\"image_index\":\$\{x:image_index},"
            "\"image_info_length\":\$\{x:image_info_length},"
            "\"image_info_format\":\$\{imageInfo.format},"
            "\"tag\":\$\{x:tag},"
            "\"size\":\$\{size},"
            "\"id\":\$\{etag}}",
        callbackVars: <String, String?>{
          'x:user_id': '3432360930586624',
          'x:description': strToBase64('咋就是说，怎么这么卡'),
          'x:topic_info': null,
          'x:mention_info': null,
          'x:location_info': null,
          'x:image_width': entity.width.toString(),
          'x:image_height': entity.height.toString(),
          'x:tag': nanoid(),
          'x:image_index': index.toString(),
          'x:image_info_length': selectedAssets.length.toString(),
        }..removeWhere((key, value) => value == null),
      );
      uploadModels.add(uploadModel);
      _uploadProcess ??= [];
      _uploadProcess?.elementAt(index)['path'] = file.path;
    });
    try {
      await _ossSdk.putObjectAsync(
        uploadModels,
        onProgress: (OssUploadResponseProcessModel processModel) async {
          final process = processModel.currentSize / processModel.totalSize;
          print('$runtimeType onProgress：${processModel.path},上传进度：$process');
          setState(() {
            _uploadProcess?.forEach((element) {
              if (element['path'] == processModel.path) {
                element['process'] = process;
              }
            });
          });
        },
        onSuccess: (OssUploadResponseSuccessModel successModel) async {
          print('onSuccess：$successModel');
          // showMsg('上传成功', 'ETag: $eTag.');
          setState(() {
            _uploadSuccessPathList.add(successModel.fileUrl);
          });
          if (_uploadSuccessPathList.length == uploadModels.length) {
            isUploading = false;
          }
        },
        onFailure: (OssUploadResponseFailureModel failureModel) async {
          showMsg('失败', '错误：$failureModel');
        },
      );
    } on PlatformException catch (e) {
      print(e);
      showMsg('PlatformException 失败',
          'code:${e.code},message:${e.message},details:${e.details},stackTrace:${e.stacktrace}');
    } catch (e, s) {
      print(e);
      print(s);
      showMsg('失败', 'code:$e,stackTrace:${s}');
    } finally {
      isUploading = false;
    }
  }

  void uploadTopicWithCallbackSync() async {
    if (selectedAssets.isEmpty) return;
    isUploading = true;

    List<OSSUploadModel> uploadModels = <OSSUploadModel>[];
    await Future.forEach(selectedAssets, (entity) async {
      // final AssetEntity entity = selectedAssets.first;
      final index =
          selectedAssets.indexWhere((element) => element.id == entity.id);
      final filename = await entity.titleAsync;
      final file = await entity.file;
      if (file == null) {
        showMsg(
          '上传失败',
          'Unable to obtain file of the entity ${entity.id}.',
        );
        return;
      }
      final String objectKey = TOPIC_FOLDER_NAME + filename;
      final OSSUploadModel uploadModel = OSSUploadModel(
        bucketName: BUCKET_NAME,
        objectKey: objectKey,
        uploadFilePath: file.path,
        customDomain: 'pic.jalagar.com',
        callbackUrl: 'http://47.107.37.194:7080/app-api/callback/topic',
        callbackBodyType: ContentType.json.mimeType,
        callbackBody: "{\"object\":\$\{object},"
            "\"topic_id\":\$\{x:topic_id},"
            "\"user_id\":\$\{x:user_id},"
            "\"image_width\":\$\{x:image_width},"
            "\"image_height\":\$\{x:image_height},"
            "\"imageInfo_format\":\$\{imageInfo.format},"
            "\"id\":\$\{etag},"
            "\"size\":\$\{size},"
            "\"tag\":\$\{x:tag},"
            "\"image_index\":\$\{x:image_index},"
            "\"image_info_length\":\$\{x:image_info_length}}",
        callbackVars: <String, String?>{
          'x:topic_id': '6854432865694638080',
          'x:user_id': '3432360930586624',
          'x:image_width': entity.width.toString(),
          'x:image_height': entity.height.toString(),
          'x:tag': nanoid(),
          'x:image_index': index.toString(),
          'x:image_info_length': selectedAssets.length.toString(),
        },
      );
      uploadModels.add(uploadModel);
      _uploadProcess ??= [];
      _uploadProcess?.elementAt(index)['path'] = file.path;
    });
    try {
      await _ossSdk.putObjectAsync(
        uploadModels,
        onProgress: (OssUploadResponseProcessModel processModel) async {
          final process = processModel.currentSize / processModel.totalSize;
          print('$runtimeType onProgress：${processModel.path},上传进度：$process');
          setState(() {
            _uploadProcess?.forEach((element) {
              if (element['path'] == processModel.path) {
                element['process'] = process;
              }
            });
          });
        },
        onSuccess: (OssUploadResponseSuccessModel successModel) async {
          print('onSuccess：$successModel');
          // showMsg('上传成功', 'ETag: $eTag.');
          setState(() {
            _uploadSuccessPathList.add(successModel.fileUrl);
          });
          if (_uploadSuccessPathList.length == uploadModels.length) {
            isUploading = false;
          }
        },
        onFailure: (OssUploadResponseFailureModel failureModel) async {
          showMsg('失败', '错误：${failureModel.errorMessage}');
        },
      );
    } on PlatformException catch (e) {
      print(e);
      showMsg('PlatformException 失败',
          'code:${e.code},message:${e.message},details:${e.details},stackTrace:${e.stacktrace}');
    } catch (e, s) {
      print(e);
      print(s);
      showMsg('失败', 'code:$e,stackTrace:${s}');
    } finally {
      isUploading = false;
    }
  }

  void uploadFeedbackWithCallbackSync() async {
    if (selectedAssets.isEmpty) return;
    isUploading = true;

    List<OSSUploadModel> uploadModels = <OSSUploadModel>[];
    await Future.forEach(selectedAssets, (entity) async {
      // final AssetEntity entity = selectedAssets.first;
      final index =
          selectedAssets.indexWhere((element) => element.id == entity.id);
      final filename = await entity.titleAsync;
      final file = await entity.file;
      if (file == null) {
        showMsg(
          '上传失败',
          'Unable to obtain file of the entity ${entity.id}.',
        );
        return;
      }
      final String objectKey = TOPIC_FOLDER_NAME + filename;
      final OSSUploadModel uploadModel = OSSUploadModel(
        bucketName: BUCKET_NAME,
        objectKey: objectKey,
        uploadFilePath: file.path,
        customDomain: 'pic.jalagar.com',
        callbackUrl: 'http://47.107.37.194:7080/app-api/callback/feedback',
        callbackBodyType: ContentType.json.mimeType,
        callbackBody: "{\"object\":\$\{object},"
            "\"type\":\$\{x:type},"
            "\"content\":\$\{x:content},"
            "\"user_id\":\$\{x:user_id},"
            "\"image_width\":\$\{x:image_width},"
            "\"image_height\":\$\{x:image_height},"
            "\"imageInfo_format\":\$\{imageInfo.format},"
            "\"id\":\$\{etag},"
            "\"size\":\$\{size},"
            "\"tag\":\$\{x:tag},"
            "\"image_index\":\$\{x:image_index},"
            "\"image_info_length\":\$\{x:image_info_length}}",
        callbackVars: <String, String?>{
          'x:content': '已有功能-建议&意见',
          'x:type': '测试反馈',
          'x:user_id': '3432360930586624',
          'x:image_width': entity.width.toString(),
          'x:image_height': entity.height.toString(),
          'x:tag': nanoid(),
          'x:image_index': index.toString(),
          'x:image_info_length': selectedAssets.length.toString(),
        },
      );
      uploadModels.add(uploadModel);
      _uploadProcess ??= [];
      _uploadProcess?.elementAt(index)['path'] = file.path;
    });
    try {
      await _ossSdk.putObjectAsync(
        uploadModels,
        onProgress: (OssUploadResponseProcessModel processModel) async {
          final process = processModel.currentSize / processModel.totalSize;
          print('$runtimeType onProgress：${processModel.path},上传进度：$process');
          setState(() {
            _uploadProcess?.forEach((element) {
              if (element['path'] == processModel.path) {
                element['process'] = process;
              }
            });
          });
        },
        onSuccess: (OssUploadResponseSuccessModel successModel) async {
          print('onSuccess：$successModel');
          // showMsg('上传成功', 'ETag: $eTag.');
          setState(() {
            _uploadSuccessPathList.add(successModel.fileUrl);
          });
          if (_uploadSuccessPathList.length == uploadModels.length) {
            isUploading = false;
          }
        },
        onFailure: (OssUploadResponseFailureModel failureModel) async {
          showMsg('失败', '错误：${failureModel.errorMessage}');
        },
      );
    } on PlatformException catch (e) {
      print(e);
      showMsg('PlatformException 失败',
          'code:${e.code},message:${e.message},details:${e.details},stackTrace:${e.stacktrace}');
    } catch (e, s) {
      print(e);
      print(s);
      showMsg('失败', 'code:$e,stackTrace:${s}');
    } finally {
      isUploading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Aliyun OSS'),
        actions: [
          if (isUploading)
            UnconstrainedBox(
              child: Container(
                constraints: BoxConstraints.tight(const Size.square(24)),
                margin: const EdgeInsets.all(8.0),
                alignment: Alignment.center,
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.0,
                ),
              ),
            )
          else
            TextButton.icon(
              onPressed: () {
                setState(() {
                  selectedAssets.clear();
                  _uploadSuccessPathList.clear();
                  _uploadProcess?.clear();
                  _uploadProcess = null;
                });
              },
              icon: const Icon(Icons.clear),
              label: Text('清除图片'),
              style: const ButtonStyle(
                foregroundColor: MaterialStatePropertyAll(Colors.white),
              ),
            ),
        ],
      ),
      body: Flex(
        direction: Axis.vertical,
        children: [
          Flexible(
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _button('初始化SDK', initSdk, color: Colors.pinkAccent),
                    _button('选择图片', _callPicker, color: Colors.indigoAccent),
                    _button('上传文件-同步', uploadSingle),
                    _button('上传文件-异步', uploadMultiSync),
                    _button('上传文件-头像回调', uploadAvatarWithCallbackSync),
                    _button('上传文件-推文回调', uploadPostWithCallbackSync),
                    _button('上传文件-话题回调', uploadTopicWithCallbackSync),
                    _button('上传文件-反馈回调', uploadTopicWithCallbackSync),
                  ],
                ),
              ),
            ),
          ),
          if (selectedAssets.isNotEmpty) _buildSelectedAssetsListView(),
          if (_uploadSuccessPathList.isNotEmpty) _buildSuccessPathListView(),
        ],
      ),
    );
  }

  Widget _buildSelectedAssetsListView() {
    return Flexible(
      child: GridView.builder(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        itemCount: selectedAssets.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
        ),
        itemBuilder: (BuildContext _, int index) {
          final AssetEntity asset = selectedAssets.elementAt(index);
          final double? process = _uploadProcess?.elementAt(index)['process'];
          final bool shouldHide = process != null && process >= 1.0;
          // print('process:$process');
          // print('shouldShowProcess:$shouldShowProcess');
          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 8.0,
              vertical: 16.0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      RepaintBoundary(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image(image: AssetEntityImageProvider(asset)),
                        ),
                      ),
                      Positioned(
                        right: -8.0,
                        top: -8.0,
                        child: IconButton(
                          onPressed: () {
                            setState(() {
                              selectedAssets.removeAt(index);
                              _uploadProcess?.removeAt(index);
                            });
                          },
                          icon: Icon(Icons.cancel),
                          iconSize: 18,
                          color: Colors.pinkAccent,
                          padding: EdgeInsets.all(0.0),
                          alignment: Alignment.topRight,
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 5.0,
                ),
                LinearProgressIndicator(
                  color: Colors.pinkAccent,
                  value: process,
                  minHeight: 3.0,
                  backgroundColor: Colors.white70,
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _button(String label, VoidCallback onTap, {Color? color}) {
    return ElevatedButton(
      onPressed: isUploading ? null : onTap,
      style: ButtonStyle(
        backgroundColor: MaterialStatePropertyAll(
          color ?? Colors.deepPurpleAccent,
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _buildSuccessPathListView() {
    return Flexible(
      child: ListView.separated(
        shrinkWrap: true,
        itemBuilder: (_, int index) {
          final path = _uploadSuccessPathList.elementAt(index);
          return ListTile(
            title: SelectableText(
              '${index + 1} - $path',
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
          );
        },
        itemCount: _uploadSuccessPathList.length,
        separatorBuilder: (BuildContext context, int index) {
          return const Divider();
        },
      ),
    );
  }

  String strToBase64(String str) {
    //base64编码 - 转utf8
    return base64.encode(utf8.encode(str));
  }
}
