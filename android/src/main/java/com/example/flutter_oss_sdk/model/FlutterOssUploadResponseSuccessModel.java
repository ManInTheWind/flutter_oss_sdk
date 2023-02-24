package com.example.flutter_oss_sdk.model;

import java.util.HashMap;
import java.util.Map;

public class FlutterOssUploadResponseSuccessModel extends FlutterOssUploadResponseModel {
    private String fileUrl;

    /// 只有设置了ServerCallback，该值才有数据。
    private String serverCallbackReturnJson;

    public FlutterOssUploadResponseSuccessModel(String path, String fileUrl, String serverCallbackReturnJson){
        setPath(path);
        setFileUrl(fileUrl);
        setServerCallbackReturnJson(serverCallbackReturnJson);
    }

    public void setFileUrl(String fileUrl) {
        this.fileUrl = fileUrl;
    }

    public void setServerCallbackReturnJson(String serverCallbackReturnJson) {
        this.serverCallbackReturnJson = serverCallbackReturnJson;
    }

    public String getFileUrl() {
        return fileUrl;
    }

    public String getServerCallbackReturnJson() {
        return serverCallbackReturnJson;
    }

   public   Map<String, Object> toJson() {
        Map<String, Object> map = new HashMap<>();
        map.put("path", getPath());
        map.put("fileUrl", getFileUrl());
        map.put("serverCallbackReturnJson", getServerCallbackReturnJson());
        return map;
    }
}
