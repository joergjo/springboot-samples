package com.example.springcloudstream.usagedetailsender;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;
import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.cloud.stream.binder.test.OutputDestination;
import org.springframework.cloud.stream.binder.test.TestChannelBinderConfiguration;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.messaging.converter.CompositeMessageConverter;

public class UsageDetailSenderApplicationTests {

	@Test
	public void contextLoads() {
	}

	@Test
	public void testUsageDetailSender() throws Exception {
		try (ConfigurableApplicationContext context = new SpringApplicationBuilder(
				TestChannelBinderConfiguration.getCompleteConfiguration(
						UsageDetailSenderApplication.class))
								.run("--spring.cloud.function.definition=sendEvents")) {
			OutputDestination target = context.getBean(OutputDestination.class);
			var sourceMessage = target.receive(10000, "usage-detail");

			assertThat(sourceMessage).isNotNull();
			var converter = context.getBean(CompositeMessageConverter.class);
			var usageDetail = (UsageDetail) converter.fromMessage(sourceMessage, UsageDetail.class);

			assertThat(usageDetail.getUserId()).isBetween("user1", "user5");
			assertThat(usageDetail.getData()).isBetween(0L, 700L);
			assertThat(usageDetail.getDuration()).isBetween(0L, 300L);
		}
	}
}