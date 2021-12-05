package com.example.springcloudstream.usagecostprocessor;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.HashMap;

import org.junit.jupiter.api.Test;
import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.cloud.stream.binder.test.InputDestination;
import org.springframework.cloud.stream.binder.test.OutputDestination;
import org.springframework.cloud.stream.binder.test.TestChannelBinderConfiguration;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.messaging.MessageHeaders;
import org.springframework.messaging.converter.CompositeMessageConverter;

public class UsageCostProcessorApplicationTests {

	@Test
	public void contextLoads() {
	}

	@Test
	public void testUsageCostProcessor() {
		try (ConfigurableApplicationContext context = new SpringApplicationBuilder(
				TestChannelBinderConfiguration.getCompleteConfiguration(
						UsageCostProcessorApplication.class))
								.run("--spring.cloud.function.definition=processUsageCost")) {

			var source = context.getBean(InputDestination.class);

			var usageDetail = new UsageDetail();
			usageDetail.setUserId("user1");
			usageDetail.setDuration(30L);
			usageDetail.setData(100L);

			var converter = context.getBean(CompositeMessageConverter.class);
			var headers = new HashMap<String, Object>();
			headers.put("contentType", "application/json");
			var messageHeaders = new MessageHeaders(headers);
			var message = converter.toMessage(usageDetail, messageHeaders);

			source.send(message, "usage-detail");

			var target = context.getBean(OutputDestination.class);
			var sourceMessage = target.receive(10000, "usage-cost");

			var usageCostDetail = (UsageCostDetail) converter.fromMessage(sourceMessage,
					UsageCostDetail.class);

			assertThat(usageCostDetail.getCallCost()).isEqualTo(3.0);
			assertThat(usageCostDetail.getDataCost()).isEqualTo(5.0);
		}
	}
}