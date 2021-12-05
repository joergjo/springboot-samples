package com.example.springcloudstream.usagecostlogger;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;

public class UsageCostDetail {

    public UsageCostDetail() {
        // default ctor
    }

    private String userId;

    private double callCost;

    private double dataCost;

    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    public double getCallCost() {
        return callCost;
    }

    public void setCallCost(double callCost) {
        this.callCost = callCost;
    }

    public double getDataCost() {
        return dataCost;
    }

    public void setDataCost(double dataCost) {
        this.dataCost = dataCost;
    }

    public String toString() {
        try {
            var om = new ObjectMapper();
            return om.writeValueAsString(this);
        } catch (JsonProcessingException e) {
            return super.toString();
        }
    }
}