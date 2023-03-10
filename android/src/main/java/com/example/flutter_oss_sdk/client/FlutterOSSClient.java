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
        OSSAuthCredentialsProvider credentialsProvider = new OSSAuthCredentialsProvider(mSTSAuthUrl);
        // ????????????????????????????????????????????????
        ClientConfiguration conf = new ClientConfiguration();
        conf.setConnectionTimeout(flutterOssConfiguration.getConnectionTimeout()); // ?????????????????????15??????
        conf.setSocketTimeout(flutterOssConfiguration.getSocketTimeout()); // socket???????????????15??????
        conf.setMaxConcurrentRequest(flutterOssConfiguration.getMaxConcurrentRequest()); // ??????????????????????????????5??????
        conf.setMaxErrorRetry(flutterOssConfiguration.getMaxErrorRetry()); // ????????????????????????????????????2??????
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
        // ?????????????????????
        // ????????????Bucket???????????????examplebucket??????Object?????????????????????exampledir/exampleobject.txt???????????????????????????????????????/storage/emulated/0/oss/examplefile.txt??????
        // Object???????????????????????????Bucket?????????
        PutObjectRequest put = new PutObjectRequest(uploadModel.getBucketName(), uploadModel.getObjectKey(), uploadModel.getUploadFilePath());
        ObjectMetadata metadata = new ObjectMetadata();
        if (uploadModel.getContentType() != null) {
            metadata.setContentType(uploadModel.getContentType());
        }
//        metadata.setContentType("application/octet-stream"); // ??????content-type???
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
            // ??????????????????????????????????????????
            Log.d(TAG, "==========???????????????==========");

            e.printStackTrace();
            result.error(FLUTTER_ERROR_CODE, e.getMessage(), Arrays.toString(e.getStackTrace()));
        } catch (ServiceException e) {
            // ??????????????????
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

        // ?????????????????????
        // ????????????Bucket???????????????examplebucket??????Object?????????????????????exampledir/exampleobject.txt???????????????????????????????????????/storage/emulated/0/oss/examplefile.txt??????
        // Object???????????????????????????Bucket?????????
        try {
            PutObjectRequest put = new PutObjectRequest(uploadModel.getBucketName(), uploadModel.getObjectKey(), uploadModel.getUploadFilePath());
            ObjectMetadata metadata = new ObjectMetadata();
            if (uploadModel.getContentType() != null) {
                metadata.setContentType(uploadModel.getContentType());
            }
            put.setMetadata(metadata);
            // ??????????????????????????????????????????
            put.setProgressCallback(new OSSProgressCallback<PutObjectRequest>() {
                @Override
                public void onProgress(PutObjectRequest request, long currentSize, long totalSize) {
                    listener.uploadProgress(new FlutterOssUploadResponseProcessModel(request.getUploadFilePath(), currentSize, totalSize));
                }
            });

            if (!containNull(uploadModel.getCallbackUrl(), uploadModel.getCallbackBody())) {
                ///????????????
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
                    // ???????????????
                    if (clientExcepion != null) {
                        // ??????????????????????????????????????????
                        clientExcepion.printStackTrace();
                        FlutterOssUploadResponseFailureModel failureModel = new FlutterOssUploadResponseFailureModel.Builder().setErrorCode(FLUTTER_ERROR_CODE).setErrorMessage("????????????:???????????????").build();
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
                        // ??????????????????
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
            return;
        }

        // ?????????????????????
        // task.cancel();
        // ???????????????????????????
        // task.waitUntilFinished();
    }
}
