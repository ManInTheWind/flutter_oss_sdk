package com.example.flutter_oss_sdk;

import android.content.Context;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import androidx.annotation.NonNull;

import com.example.flutter_oss_sdk.client.FlutterOSSClient;
import com.example.flutter_oss_sdk.delegate.FlutterOSSUploadListener;
import com.example.flutter_oss_sdk.model.FlutterOSSClientConfiguration;
import com.example.flutter_oss_sdk.model.FlutterOSSUploadModel;
import com.example.flutter_oss_sdk.model.FlutterOssUploadResponseFailureModel;
import com.example.flutter_oss_sdk.model.FlutterOssUploadResponseProcessModel;
import com.example.flutter_oss_sdk.model.FlutterOssUploadResponseSuccessModel;
import com.google.gson.Gson;

import java.util.ArrayList;
import java.util.List;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/**
 * FlutterOssSdkPlugin
 */
public class FlutterOssSdkPlugin implements FlutterPlugin, MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private String mSTSAuthUrl;

    private String mOSSEndPoint;

    private Context context;

    private MethodChannel channel;


    private static final String TAG = FlutterOssSdkPlugin.class.getSimpleName();

    private static final String FLUTTER_ERROR_CODE = "-1";

    private FlutterOSSClient flutterOSSClient;


    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        flutterOSSClient = new FlutterOSSClient();
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "flutter_oss_sdk");
        channel.setMethodCallHandler(this);
        context = flutterPluginBinding.getApplicationContext();
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        switch (call.method) {
            case "getPlatformVersion":
                result.success("Android " + android.os.Build.VERSION.RELEASE);
                break;
            case "initOSSClient":
                initSdk(call.arguments, result);
                break;
            case "putObject":
                pubObject(call.arguments, result);
                break;
            case "putObjectAsync":
                putObjectAsync(call.arguments, result);
                break;
            default:
                result.notImplemented();

        }

    }

    /**
     * 初始化
     *
     * @param arguments 参数
     * @param result    返回结果
     */
    public void initSdk(Object arguments, Result result) {
        FlutterOSSClientConfiguration flutterOssConfiguration;
        try {
            Gson gson = new Gson();
            String jsonBean = gson.toJson(arguments);
            flutterOssConfiguration = gson.fromJson(jsonBean, FlutterOSSClientConfiguration.class);
        } catch (Exception e) {
            Log.e(TAG, "解析arguments遇到错误：" + e);
            result.error(FLUTTER_ERROR_CODE, e.getMessage(), e.getStackTrace());
            return;
        }
        flutterOSSClient.init(context, flutterOssConfiguration, result);
    }

    /**
     * 同步上传单个文件
     *
     * @param arguments 参数
     * @param result    返回结果
     */
    public void pubObject(Object arguments, Result result) {
        FlutterOSSUploadModel uploadModel;
        try {
            Gson gson = new Gson();
            String jsonBean = gson.toJson(arguments);
            uploadModel = gson.fromJson(jsonBean, FlutterOSSUploadModel.class);
        } catch (Exception e) {
            Log.e(TAG, "解析arguments遇到错误：" + e);
            result.error(FLUTTER_ERROR_CODE, e.getMessage(), e.getStackTrace());
            return;
        }
        flutterOSSClient.putObject(uploadModel, result);
    }

    /**
     * 异步上传单个或多个文件
     *
     * @param arguments 参数
     * @param result    返回结果
     */
    public void putObjectAsync(Object arguments, Result result) {
        List<FlutterOSSUploadModel> uploadModels = new ArrayList<>();
        try {
            for (Object o : (List<?>) arguments) {
                Gson gson = new Gson();
                String jsonBean = gson.toJson(o);
                FlutterOSSUploadModel uploadModel = gson.fromJson(jsonBean, FlutterOSSUploadModel.class);
                uploadModels.add(uploadModel);
            }
        } catch (Exception e) {
            Log.e(TAG, "解析arguments遇到错误：" + e);
            result.error(FLUTTER_ERROR_CODE, e.getMessage(), e.getStackTrace());
            return;
        }


        Thread thread = new Thread(() -> {
            flutterOSSClient.pubObjectAsync(uploadModels, new FlutterOSSUploadListener() {
                @Override
                public void uploadProgress(FlutterOssUploadResponseProcessModel processModel) {
                    new Handler(Looper.getMainLooper()).post(() -> channel.invokeMethod("onProgress", processModel.toJson()));
                }

                @Override
                public void uploadSuccess(FlutterOssUploadResponseSuccessModel successModel) {
                    new Handler(Looper.getMainLooper()).post(() -> channel.invokeMethod("onSuccess", successModel.toJson()));
                }

                @Override
                public void uploadFailed(FlutterOssUploadResponseFailureModel failureModel) {
                    new Handler(Looper.getMainLooper()).post(() -> channel.invokeMethod("onFailure", failureModel.toJson()));
                }
            });
        });
        thread.start();
        result.success(true);
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }


}
