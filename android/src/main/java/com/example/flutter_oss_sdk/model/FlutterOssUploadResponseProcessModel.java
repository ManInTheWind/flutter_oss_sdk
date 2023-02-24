package com.example.flutter_oss_sdk.model;

import java.util.HashMap;
import java.util.Map;

public class FlutterOssUploadResponseProcessModel extends FlutterOssUploadResponseModel {
    private Long currentSize;
    private Long totalSize;

    public FlutterOssUploadResponseProcessModel(String path, long currentSize, long totalSize) {
        setPath(path);
        setCurrentSize(currentSize);
        setTotalSize(totalSize);
    }

    public void setCurrentSize(Long currentSize) {
        this.currentSize = currentSize;
    }

    public void setTotalSize(Long totalSize) {
        this.totalSize = totalSize;
    }

    public Long getCurrentSize() {
        return currentSize;
    }

    public Long getTotalSize() {
        return totalSize;
    }

   public Map<String, Object> toJson() {
        Map<String, Object> map = new HashMap<>();
        map.put("path", getPath());
        map.put("currentSize", getCurrentSize());
        map.put("totalSize", getTotalSize());
        return map;
    }
}
