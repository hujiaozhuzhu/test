package com.vuln.app;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.jackson.JacksonAutoConfiguration;

@SpringBootApplication(exclude = {JacksonAutoConfiguration.class})
public class VulnApplication {
    public static void main(String[] args) {
        SpringApplication.run(VulnApplication.class, args);
    }
}
