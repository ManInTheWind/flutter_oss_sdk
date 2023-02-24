package com.example.flutter_oss_sdk.model;

import java.util.HashMap;
import java.util.Map;

public class FlutterOssUploadResponseFailureModel extends FlutterOssUploadResponseModel {
    private String errorCode;
    private String requestId;
    private String hostId;
    private String errorMessage;

    public static class Builder {
        public String errorCode;
        public String requestId;
        public String hostId;
        public String errorMessage;


        public Builder setErrorCode(String errorCode) {
            this.errorCode = errorCode;
            return this;
        }

        public Builder setRequestId(String requestId) {
            this.requestId = requestId;
            return this;

        }

        public Builder setHostId(String hostId) {
            this.hostId = hostId;
            return this;

        }

        public Builder setErrorMessage(String errorMessage) {
            this.errorMessage = errorMessage;
            return this;
        }

        public FlutterOssUploadResponseFailureModel build() {
            FlutterOssUploadResponseFailureModel failureModel = new FlutterOssUploadResponseFailureModel();
            failureModel.errorCode = errorCode;
            failureModel.requestId = errorCode;
            failureModel.hostId = errorCode;
            failureModel.errorMessage = errorCode;
            return failureModel;
        }
    }

    public Map<String, Object> toJson() {
        Map<String, Object> map = new HashMap<>();
        map.put("path", getPath());
        map.put("errorCode", errorCode);
        map.put("requestId", requestId);
        map.put("hostId", hostId);
        map.put("errorMessage", errorMessage);
        return map;
    }
}
