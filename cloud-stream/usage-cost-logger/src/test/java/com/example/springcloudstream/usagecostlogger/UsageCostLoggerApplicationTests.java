package com.example.springcloudstream.usagecostlogger;

import java.util.HashMap;

import org.awaitility.Awaitility;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.boot.test.system.CapturedOutput;
import org.springframework.boot.test.system.OutputCaptureExtension;
import org.springframework.cloud.stream.binder.test.InputDestination;
import org.springframework.cloud.stream.binder.test.TestChannelBinderConfiguration;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.messaging.MessageHeaders;
import org.springframework.messaging.converter.CompositeMessageConverter;

@ExtendWith(OutputCaptureExtension.class)
public class UsageCostLoggerApplicationTests {

	@Test
	public void contextLoads() {
	}

	@Test
	public void testUsageCostLogger(CapturedOutput output) {
		try (ConfigurableApplicationContext context = new SpringApplicationBuilder(
				TestChannelBinderConfiguration.getCompleteConfiguration(UsageCostLoggerApplication.class))
						.run("--spring.cloud.function.definition=process")) {

			var source = context.getBean(InputDestination.class);

			var usageCostDetail = new UsageCostDetail();
			usageCostDetail.setUserId("user1");
			usageCostDetail.setCallCost(3.0);
			usageCostDetail.setDataCost(5.0);

			var converter = context.getBean(CompositeMessageConverter.class);
			var headers = new HashMap<String, Object>();
			headers.put("contentType", "application/json");
			var messageHeaders = new MessageHeaders(headers);
			var message = converter.toMessage(usageCostDetail, messageHeaders);

			source.send(message, "usage-cost");

			Awaitility.await().until(output::getOut,
					value -> value.contains("{\"userId\":\"user1\",\"callCost\":3.0,\"dataCost\":5.0}"));
		}
	}
}
