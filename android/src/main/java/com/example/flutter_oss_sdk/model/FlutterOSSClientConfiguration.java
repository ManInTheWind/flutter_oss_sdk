package com.example.flutter_oss_sdk.model;

public class FlutterOSSClientConfiguration {
    ///STS应用服务器地址
    private String ossStsUrl;

    ///阿里云OSS服务
    private String bucketEndPoint;

    ///设置是否开启DNS配置
    private Boolean httpDnsEnable = true;

    ///设置自定义user-agent
    private String userAgentMark;

    ///设置网络参数
    ///连接超时，默认15秒
    private Integer connectionTimeout;

    ///socket超时，默认15秒
    private Integer socketTimeout;

    ///最大并发请求书，默认5个
    private Integer maxConcurrentRequest;

    ///失败后最大重试次数，默认2次
    private Integer maxErrorRetry;


    ///是否开启开启日志
    private Boolean enableLog;

    public void setOssStsUrl(String ossStsUrl) {
        this.ossStsUrl = ossStsUrl;
    }

    public void setBucketEndPoint(String bucketEndPoint) {
        this.bucketEndPoint = bucketEndPoint;
    }

    public void setHttpDnsEnable(Boolean httpDnsEnable) {
        this.httpDnsEnable = httpDnsEnable;
    }

    public void setUserAgentMark(String userAgentMark) {
        this.userAgentMark = userAgentMark;
    }

    public void setConnectionTimeout(Integer connectionTimeout) {
        this.connectionTimeout = connectionTimeout;
    }

    public void setSocketTimeout(Integer socketTimeout) {
        this.socketTimeout = socketTimeout;
    }

    public void setMaxConcurrentRequest(Integer maxConcurrentRequest) {
        this.maxConcurrentRequest = maxConcurrentRequest;
    }

    public void setMaxErrorRetry(Integer maxErrorRetry) {
        this.maxErrorRetry = maxErrorRetry;
    }

    public void setEnableLog(Boolean enableLog) {
        this.enableLog = enableLog;
    }

    public Boolean getEnableLog() {
        return enableLog;
    }

    public String getOssStsUrl() {
        return ossStsUrl;
    }

    public String getBucketEndPoint() {
        return bucketEndPoint;
    }

    public Boolean getHttpDnsEnable() {
        return httpDnsEnable;
    }

    public String getUserAgentMark() {
        return userAgentMark;
    }

    public Integer getConnectionTimeout() {
        return connectionTimeout;
    }

    public Integer getSocketTimeout() {
        return socketTimeout;
    }

    public Integer getMaxConcurrentRequest() {
        return maxConcurrentRequest;
    }

    public Integer getMaxErrorRetry() {
        return maxErrorRetry;
    }
}
