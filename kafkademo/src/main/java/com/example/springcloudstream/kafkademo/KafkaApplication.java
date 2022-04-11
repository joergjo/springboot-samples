package com.example.springcloudstream.kafkademo;

import java.util.concurrent.atomic.AtomicInteger;
import java.util.function.Consumer;
import java.util.function.Supplier;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.stream.config.ListenerContainerCustomizer;
import org.springframework.context.annotation.Bean;
import org.springframework.data.domain.Example;
import org.springframework.kafka.listener.AbstractMessageListenerContainer;
import org.springframework.kafka.listener.SeekToCurrentErrorHandler;
import org.springframework.kafka.support.KafkaHeaders;
import org.springframework.messaging.Message;
import org.springframework.util.backoff.FixedBackOff;

import reactor.core.publisher.Flux;
import reactor.core.publisher.Sinks;

@SpringBootApplication
public class KafkaApplication {
    private final MessageReceiptRepository repository;
    private final AtomicInteger counter = new AtomicInteger();
    private static final Logger logger = LoggerFactory.getLogger(KafkaApplication.class);

    public KafkaApplication(MessageReceiptRepository repository) {
        this.repository = repository;
    }

    public static void main(String[] args) {
        SpringApplication.run(KafkaApplication.class, args);
    }

    @Bean
    public Sinks.Many<Message<String>> many() {
        return Sinks.many().unicast().onBackpressureBuffer();
    }

    @Bean
    public Supplier<Flux<Message<String>>> supply(Sinks.Many<Message<String>> many) {
        return () -> many.asFlux()
                .doOnNext(m -> logger.info("Manually sending message {}", m))
                .doOnError(t -> logger.error("Error encountered", t));
    }

    @Bean
    public Consumer<Message<String>> consume() {
        return message -> {
            var count = counter.incrementAndGet();
            logger.info("Consumer called: {}", count);
            var offset = message.getHeaders().get(KafkaHeaders.OFFSET, Long.class);
            var key = message.getHeaders().get(KafkaHeaders.RECEIVED_MESSAGE_KEY,
                    String.class);
            var partitionId = message.getHeaders().get(KafkaHeaders.RECEIVED_PARTITION_ID, Integer.class);

            if (repository.exists(Example.of(new MessageReceipt(partitionId, offset)))) {
                logger.warn("Duplicate message received on partition '{}' at offset '{}' with key '{}', ignoring",
                        partitionId, offset, key);
                return;
            }

            repository.save(new MessageReceipt(partitionId, offset));
            logger.info("New message received on partition '{}' at offset '{}'' with key '{}': '{}'", partitionId,
                    offset, key, message.getPayload());
            counter.set(0);
        };
    }

    // See https://github.com/spring-cloud/spring-cloud-stream-binder-kafka/issues/1135
    // TODO: Why is this still required?
    @Bean
    public ListenerContainerCustomizer<AbstractMessageListenerContainer<?, ?>> listenerContainerCustomizer() {
        return (container, dest, group) -> container
                .setErrorHandler(new SeekToCurrentErrorHandler(new FixedBackOff(0, 0)));
    }

    @Bean
    public Consumer<Message<String>> consumeWithErrors() {
        return message -> {
            // If we crash immediately, Spring Cloud Stream will retry the message
            if (message.getPayload().equalsIgnoreCase("crash")) {
                throw new RuntimeException("Crashing immediately!");
            }

            var fail = false;
            if (message.getPayload().equalsIgnoreCase("fail")) {
                var i = counter.getAndIncrement();
                fail = (i < 2);
                if (!fail) {
                    counter.set(0);
                }
            }

            var offset = message.getHeaders().get(KafkaHeaders.OFFSET, Long.class);
            var key = message.getHeaders().get(KafkaHeaders.RECEIVED_MESSAGE_KEY,
                    String.class);
            var partitionId = message.getHeaders().get(KafkaHeaders.RECEIVED_PARTITION_ID, Integer.class);

            if (repository.exists(Example.of(new MessageReceipt(partitionId, offset)))) {
                logger.warn("Duplicate message received on partition '{}' at offset '{}' with key '{}', ignoring",
                        partitionId, offset, key);
                if (fail) {
                    throw new RuntimeException("Failure after duplicate detection!");
                }
                return;
            }

            repository.save(new MessageReceipt(partitionId, offset));
            logger.info("New message received on partition '{}' at offset '{}'' with key '{}': '{}'", partitionId,
                    offset, key, message.getPayload());

            if (fail) {
                throw new RuntimeException("Failure after work has been done!");
            }
        };
    }
}