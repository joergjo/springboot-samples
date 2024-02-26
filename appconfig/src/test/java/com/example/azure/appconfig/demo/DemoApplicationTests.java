package com.example.azure.appconfig.demo;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;

@SpringBootTest(properties = "spring.cloud.azure.appconfiguration.enabled=false")
class DemoApplicationTests {

	@Test
	void contextLoads() {
	}

}
