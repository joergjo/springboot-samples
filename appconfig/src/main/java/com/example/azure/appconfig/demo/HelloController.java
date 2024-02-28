package com.example.azure.appconfig.demo;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import com.azure.spring.cloud.appconfiguration.config.AppConfigurationRefresh;

@RestController
public class HelloController {
    private final MessageProperties properties;

    @Autowired(required = false)
    private AppConfigurationRefresh refresh;

    public HelloController(MessageProperties properties) {
        this.properties = properties;
    }

    @GetMapping
    public String getMessage() {
        if (refresh != null) {
            refresh.refreshConfigurations();
        }
        return "Message: " + properties.getMessage();
    }

    @GetMapping("/buildinfo")
    public BuildInfo getBuildInfo() {
        return properties.getBuildInfo();
    } 

    @GetMapping("/keyvault")
    public String getKeyVaultMessage() {
        return "KeyVaultMessage: " + properties.getKeyVaultMessage();
    }
}
