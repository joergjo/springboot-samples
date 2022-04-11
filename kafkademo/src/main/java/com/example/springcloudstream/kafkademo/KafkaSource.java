package com.example.springcloudstream.kafkademo;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.messaging.Message;
import org.springframework.messaging.support.GenericMessage;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import reactor.core.publisher.Sinks;

@RestController
public class KafkaSource {
    @Autowired
    private Sinks.Many<Message<String>> many;

    @PostMapping("/messages")
    public String sendMessage(@RequestParam String message) {
        many.emitNext(new GenericMessage<>(message), Sinks.EmitFailureHandler.FAIL_FAST);
        return message;
    }
}
