package com.example.flutter_oss_sdk.client;

import android.content.Context;
import android.os.Build;
import android.util.Log;

import com.alibaba.sdk.android.oss.ClientConfiguration;
import com.alibaba.sdk.android.oss.ClientException;
import com.alibaba.sdk.android.oss.OSS;
import com.alibaba.sdk.android.oss.OSSClient;
import com.alibaba.sdk.android.oss.ServiceException;
import com.alibaba.sdk.android.oss.callback.OSSCompletedCallback;
import com.alibaba.sdk.android.oss.callback.OSSProgressCallback;
import com.alibaba.sdk.android.oss.common.OSSLog;
import com.alibaba.sdk.android.oss.common.auth.OSSAuthCredentialsProvider;
import com.alibaba.sdk.android.oss.internal.OSSAsyncTask;
import com.alibaba.sdk.android.oss.model.ObjectMetadata;
import com.alibaba.sdk.android.oss.model.PutObjectRequest;
import com.alibaba.sdk.android.oss.model.PutObjectResult;
import com.example.flutter_oss_sdk.delegate.FlutterOSSDelegate;
import com.example.flutter_oss_sdk.delegate.FlutterOSSUploadListener;
import com.example.flutter_oss_sdk.model.FlutterOSSClientConfiguration;
import com.example.flutter_oss_sdk.model.FlutterOSSUploadModel;
import com.example.flutter_oss_sdk.model.FlutterOssUploadResponseFailureModel;
import com.example.flutter_oss_sdk.model.FlutterOssUploadResponseProcessModel;
import com.example.flutter_oss_sdk.model.FlutterOssUploadResponseSuccessModel;

import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Optional;

import io.flutter.plugin.common.MethodChannel;

public class FlutterOSSClient implements FlutterOSSDelegate {
    private static final String TAG = FlutterOSSClient.class.getSimpleName();

    private static final String FLUTTER_ERROR_CODE = "-1";

    private String mSTSAuthUrl;

    private String mOSSEndPoint;

    private OSS oss;

    private boolean containNull(Object... arguments) {
        return Arrays.asList(arguments).contains(null);
    }

    @Override
    public void init(Context context, FlutterOSSClientConfiguration flutterOssConfiguration, MethodChannel.Result result) {
        mSTSAuthUrl = flutterOssConfiguration.getOssStsUrl();
        mOSSEndPoint = flutterOssConfiguration.getBucketEndPoint();
        if (mSTSAuthUrl == null) {
            result.error(FLUTTER_ERROR_CODE, "STS Auth链接为空", null);
            return;
        }
        OSSAuthCredentialsProvider credentialsProvider = new OSSAuthCredentialsProvider(mSTSAuthUrl);
        // 配置类如果不设置，会有默认配置。
        ClientConfiguration conf = new ClientConfiguration();
        if (flutterOssConfiguration.getConnectionTimeout() != null) {
            conf.setConnectionTimeout(flutterOssConfiguration.getConnectionTimeout()); // 连接超时，默认15秒。
        }
        if (flutterOssConfiguration.getSocketTimeout() != null) {
            conf.setSocketTimeout(flutterOssConfiguration.getSocketTimeout()); // socket超时，默认15秒。
        }
        if (flutterOssConfiguration.getMaxConcurrentRequest() != null) {
            conf.setMaxConcurrentRequest(flutterOssConfiguration.getMaxConcurrentRequest()); // 最大并发请求数，默认5个。
        }
        if (flutterOssConfiguration.getMaxErrorRetry() != null) {
            conf.setMaxErrorRetry(flutterOssConfiguration.getMaxErrorRetry()); // 失败后最大重试次数，默认2次。
        }
        // 是否开启httpDns。
        conf.setHttpDnsEnable(flutterOssConfiguration.getHttpDnsEnable());
        if (flutterOssConfiguration.getUserAgentMark() != null) {
            conf.setUserAgentMark(flutterOssConfiguration.getUserAgentMark());
        }
        if (flutterOssConfiguration.getEnableLog()) {
            OSSLog.enableLog();
        }
        oss = new OSSClient(context, mOSSEndPoint, credentialsProvider);
        result.success(true);
    }

    @Override
    public void putObject(FlutterOSSUploadModel uploadModel, MethodChannel.Result result) {
        // 构造上传请求。
        // 依次填写Bucket名称（例如examplebucket）、Object完整路径（例如exampledir/exampleobject.txt）和本地文件完整路径（例如/storage/emulated/0/oss/examplefile.txt）。
        // Object完整路径中不能包含Bucket名称。
        PutObjectRequest put = new PutObjectRequest(uploadModel.getBucketName(), uploadModel.getObjectKey(), uploadModel.getUploadFilePath());
        ObjectMetadata metadata = new ObjectMetadata();
        if (uploadModel.getContentType() != null) {
            metadata.setContentType(uploadModel.getContentType());
        }
//        metadata.setContentType("application/octet-stream"); // 设置content-type。
        put.setMetadata(metadata);
        try {
            PutObjectResult putResult = oss.putObject(put);
//            Log.d("PutObject", "UploadSuccess");
//            Log.d("ETag", putResult.getETag());
//            Log.d("RequestId", putResult.getRequestId());
            String domain;
            if (uploadModel.getCustomDomain() != null) {
                domain = uploadModel.getCustomDomain();
            } else {
                domain = uploadModel.getBucketName() + "." + mOSSEndPoint;
            }

            String ossFileUrl = "https://" +
                    domain +
                    "/" +
                    uploadModel.getObjectKey();
            result.success(ossFileUrl);
        } catch (ClientException e) {
            // 客户端异常，例如网络异常等。
            Log.d(TAG, "==========客户端异常==========");

            e.printStackTrace();
            result.error(FLUTTER_ERROR_CODE, e.getMessage(), Arrays.toString(e.getStackTrace()));
        } catch (ServiceException e) {
            // 服务端异常。
            Log.e("RequestId", e.getRequestId());
            Log.e("ErrorCode", e.getErrorCode());
            Log.e("HostId", e.getHostId());
            Log.e("RawMessage", e.getRawMessage());
            result.error(e.getErrorCode(), e.getRawMessage(), e.getStackTrace());
        }
    }

    @Override
    public void pubObjectAsync(List<FlutterOSSUploadModel> uploadModelList, FlutterOSSUploadListener listener) {
        FlutterOSSUploadModel uploadModel = uploadModelList.get(0);

        // 构造上传请求。
        // 依次填写Bucket名称（例如examplebucket）、Object完整路径（例如exampledir/exampleobject.txt）和本地文件完整路径（例如/storage/emulated/0/oss/examplefile.txt）。
        // Object完整路径中不能包含Bucket名称。
        try {
            PutObjectRequest put = new PutObjectRequest(uploadModel.getBucketName(), uploadModel.getObjectKey(), uploadModel.getUploadFilePath());
            ObjectMetadata metadata = new ObjectMetadata();
            if (uploadModel.getContentType() != null) {
                metadata.setContentType(uploadModel.getContentType());
            }
            put.setMetadata(metadata);
            // 异步上传时可以设置进度回调。
            put.setProgressCallback(new OSSProgressCallback<PutObjectRequest>() {
                @Override
                public void onProgress(PutObjectRequest request, long currentSize, long totalSize) {
                    listener.uploadProgress(new FlutterOssUploadResponseProcessModel(request.getUploadFilePath(), currentSize, totalSize));
                }
            });

            if (!containNull(uploadModel.getCallbackUrl(), uploadModel.getCallbackBody())) {
                ///上传回调
                put.setCallbackParam(new HashMap<String, String>() {
                    {
                        put("callbackUrl", uploadModel.getCallbackUrl());
                        if (uploadModel.getCallbackHost() != null) {
                            put("callbackHost", uploadModel.getCallbackHost());
                        }
                        if (uploadModel.getCallbackBodyType() != null) {
                            put("callbackBodyType", uploadModel.getCallbackBodyType());
                        }
                        put("callbackBody", uploadModel.getCallbackBody());
                    }
                });
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                    Optional.ofNullable(uploadModel.getCallbackVars()).ifPresent(put::setCallbackVars);
                } else {
                    if (uploadModel.getCallbackVars() != null) {
                        put.setCallbackVars(uploadModel.getCallbackVars());
                    }
                }
            }

            OSSAsyncTask<PutObjectResult> task = oss.asyncPutObject(put, new OSSCompletedCallback<PutObjectRequest, PutObjectResult>() {
                @Override
                public void onSuccess(PutObjectRequest request, PutObjectResult result) {

                    String domain;

                    if (uploadModel.getCustomDomain() != null) {
                        domain = uploadModel.getCustomDomain();
                    } else {
                        domain = uploadModel.getBucketName() + "." + mOSSEndPoint;
                    }

                    String ossFileUrl = "https://" +
                            domain +
                            "/" +
                            uploadModel.getObjectKey();

                    listener.uploadSuccess(new FlutterOssUploadResponseSuccessModel(request.getUploadFilePath(), ossFileUrl, result.getServerCallbackReturnBody()));

                    uploadModelList.remove(0);

                    if (!uploadModelList.isEmpty()) {
                        pubObjectAsync(uploadModelList, listener);
                    }
                }

                @Override
                public void onFailure(PutObjectRequest request, ClientException clientExcepion, ServiceException serviceException) {
                    // 请求异常。
                    if (clientExcepion != null) {
                        // 客户端异常，例如网络异常等。
                        clientExcepion.printStackTrace();
                        FlutterOssUploadResponseFailureModel failureModel = new FlutterOssUploadResponseFailureModel.Builder().setErrorCode(FLUTTER_ERROR_CODE).setErrorMessage("上传失败:客户端异常").build();
                        listener.uploadFailed(failureModel);
                    }
                    if (serviceException != null) {
                        FlutterOssUploadResponseFailureModel failureModel = new FlutterOssUploadResponseFailureModel.Builder()
                                .setErrorCode(serviceException.getErrorCode())
                                .setRequestId(serviceException.getRequestId())
                                .setHostId(serviceException.getHostId())
                                .setErrorMessage(serviceException.getRawMessage())
                                .build();
                        listener.uploadFailed(failureModel);
                        // 服务端异常。
                        Log.e("ErrorCode", serviceException.getErrorCode());
                        Log.e("RequestId", serviceException.getRequestId());
                        Log.e("HostId", serviceException.getHostId());
                        Log.e("RawMessage", serviceException.getRawMessage());
                    }
                }
            });
        } catch (Exception e) {
            FlutterOssUploadResponseFailureModel failureModel = new FlutterOssUploadResponseFailureModel.Builder()
                    .setErrorCode(FLUTTER_ERROR_CODE)
                    .setErrorMessage(e.getMessage())
                    .build();
            listener.uploadFailed(failureModel);
        }

        // 取消上传任务。
        // task.cancel();
        // 等待上传任务完成。
        // task.waitUntilFinished();
    }
}
