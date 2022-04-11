package com.example.springcloudstream.kafkademo;

import javax.persistence.Entity;
import javax.persistence.Id;

@Entity
public class MessageReceipt {
    @Id
    private Integer partitionId;

    private Long lastOffset;

    public MessageReceipt() {
    }

    public MessageReceipt(Integer partitionId, Long lastOffset) {
        this.partitionId = partitionId;
        this.lastOffset = lastOffset;
    }

    public Integer getPartitionId() {
        return partitionId;
    }

    public void setPartitonId(Integer partitionId) {
        this.partitionId = partitionId;
    }

    public Long getLastOffset() {
        return lastOffset;
    }

    public void setLastOffset(Long lastOffset) {
        this.lastOffset = lastOffset;
    }
}
