package com.example.springcloudstream.usagedetailsender;

import java.util.Random;
import java.util.function.Supplier;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class UsageDetailSender {

    private static final String[] users = { "user1", "user2", "user3", "user4", "user5" };
    private final Random random = new Random();

    @Bean
    public Supplier<UsageDetail> sendEvents() {
        return () -> {
            var usageDetail = new UsageDetail();
            usageDetail.setUserId(users[random.nextInt(5)]);
            usageDetail.setDuration(random.nextInt(300));
            usageDetail.setData(random.nextInt(700));
            return usageDetail;
        };
    }
}
