package com.example.azure.eventhub;

import java.util.function.Consumer;

import com.azure.messaging.eventhubs.EventProcessorClient;
import com.azure.messaging.eventhubs.EventProcessorClientBuilder;
import com.azure.messaging.eventhubs.checkpointstore.blob.BlobCheckpointStore;
import com.azure.messaging.eventhubs.models.ErrorContext;
import com.azure.messaging.eventhubs.models.EventContext;
import com.azure.storage.blob.BlobContainerClientBuilder;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.DisposableBean;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

@Component
public class EventHubWorker implements DisposableBean {
    @Value("${eventhub.connection-string}")
    private String eventHubConnectionString;

    @Value("${eventhub.name}")
    private String eventHubName;

    @Value("${eventhub.consumer-group:$Default}")
    private String consumerGroup;

    @Value("${storage.connection-string}")
    private String storageConnectionString; 

    @Value("${storage.container-name}")
    private String containerName;

    private EventProcessorClient eventProcessorClient;
    private final Logger logger = LoggerFactory.getLogger(EventHubWorker.class);

    public EventHubWorker() {
    }

    public void run() {
        logger.info("Worker is starting");
        var blobContainerAsyncClient = new BlobContainerClientBuilder().connectionString(storageConnectionString).containerName(containerName).buildAsyncClient();
 
        Consumer<EventContext> processEvent = eventContext -> {
            logger.info(
                    "Processing event: Event Hub name = {}; consumer group name = {}; partition id = {}; sequence number = {}",
                    eventContext.getPartitionContext().getEventHubName(),
                    eventContext.getPartitionContext().getConsumerGroup(),
                    eventContext.getPartitionContext().getPartitionId(),
                    eventContext.getEventData().getSequenceNumber());

            eventContext.updateCheckpoint();
        };

        Consumer<ErrorContext> processError = errorContext -> {
            logger.error("Error while processing {}, {}, {}, {}", errorContext.getPartitionContext().getEventHubName(),
                    errorContext.getPartitionContext().getConsumerGroup(),
                    errorContext.getPartitionContext().getPartitionId(), errorContext.getThrowable().getMessage());
        };

        eventProcessorClient = new EventProcessorClientBuilder()
                .consumerGroup(consumerGroup)
                .connectionString(eventHubConnectionString, eventHubName).processEvent(processEvent).processError(processError)
                .checkpointStore(new BlobCheckpointStore(blobContainerAsyncClient)).buildEventProcessorClient();

        eventProcessorClient.start();
        logger.info("Worker has started");
    }

    @Override
    public void destroy() throws Exception {
        logger.info("Working is stopping");
        if (eventProcessorClient.isRunning()) {
            eventProcessorClient.stop();
        }
        logger.info("Worker has stopped");
    }
}
