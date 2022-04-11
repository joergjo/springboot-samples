package com.example.springcloudstream.kafkademo;

import org.springframework.data.jpa.repository.JpaRepository;

public interface MessageReceiptRepository extends JpaRepository<MessageReceipt, Long> {
}