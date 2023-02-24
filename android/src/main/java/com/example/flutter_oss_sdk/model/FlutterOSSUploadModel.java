package com.example.flutter_oss_sdk.model;

import java.util.Map;

public class FlutterOSSUploadModel {
    private String bucketName;
    private String objectKey;
    private String uploadFilePath;

    /**
     * 自定义域名
     */
    private String customDomain;

    private String callbackUrl;
    private String callbackHost;
    private String callbackBodyType;
    private String callbackBody;
    private Map<String, String> callbackVars;

    public void setBucketName(String bucketName) {
        this.bucketName = bucketName;
    }

    public void setObjectKey(String objectKey) {
        this.objectKey = objectKey;
    }

    public void setUploadFilePath(String uploadFilePath) {
        this.uploadFilePath = uploadFilePath;
    }

    public String getBucketName() {
        return bucketName;
    }

    public String getObjectKey() {
        return objectKey;
    }

    public String getUploadFilePath() {
        return uploadFilePath;
    }

    public void setCallbackUrl(String callbackUrl) {
        this.callbackUrl = callbackUrl;
    }

    public void setCallbackHost(String callbackHost) {
        this.callbackHost = callbackHost;
    }

    public void setCallbackBodyType(String callbackBodyType) {
        this.callbackBodyType = callbackBodyType;
    }

    public void setCallbackBody(String callbackBody) {
        this.callbackBody = callbackBody;
    }

    public void setCallbackVars(Map<String, String> callbackVars) {
        this.callbackVars = callbackVars;
    }

    public String getCallbackUrl() {
        return callbackUrl;
    }

    public String getCallbackHost() {
        return callbackHost;
    }

    public String getCallbackBodyType() {
        return callbackBodyType;
    }

    public String getCallbackBody() {
        return callbackBody;
    }

    public Map<String, String> getCallbackVars() {
        return callbackVars;
    }

    public String getCustomDomain() {
        return customDomain;
    }

    public void setCustomDomain(String customDomain) {
        this.customDomain = customDomain;
    }
}
