package com.example.flutter_oss_sdk.model;

public abstract class FlutterOssUploadResponseModel {
    private String path;

    public void setPath(String path) {
        this.path = path;
    }

    public String getPath() {
        return path;
    }
}
