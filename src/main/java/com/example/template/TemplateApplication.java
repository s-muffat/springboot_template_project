package com.example.template;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

@SpringBootApplication
public class TemplateApplication {
    private static final Logger LOGGER = LogManager.getLogger(TemplateApplication.class);

    public static void main(String[] args) {
        SpringApplication.run(TemplateApplication.class, args);

        LOGGER.info("Application started successfully");
    }

}