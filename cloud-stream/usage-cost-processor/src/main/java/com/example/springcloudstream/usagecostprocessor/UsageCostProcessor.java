package com.example.springcloudstream.usagecostprocessor;

import java.util.function.Function;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class UsageCostProcessor {
    private static final double RATE_PER_SECOND = 0.1;
    private static final double RATE_PER_MB = 0.05;

    @Bean
    public Function<UsageDetail, UsageCostDetail> processUsageCost() {
        return usageDetail -> {
            var usageCostDetail = new UsageCostDetail();
            usageCostDetail.setUserId(usageDetail.getUserId());
            usageCostDetail.setCallCost(usageDetail.getDuration() * RATE_PER_SECOND);
            usageCostDetail.setDataCost(usageDetail.getData() * RATE_PER_MB);
            return usageCostDetail;
        };
    }
}
