package com.example.azure.eventhub;

import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;

@SpringBootApplication
public class ConsumerApplication {
	@Bean
	public CommandLineRunner runWorker(EventHubWorker worker) {
		return args -> {
			worker.run();
		};
	} 

	public static void main(String[] args) {
		SpringApplication.run(ConsumerApplication.class, args);
	}
}
