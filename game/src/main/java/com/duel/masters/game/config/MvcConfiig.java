package com.duel.masters.game.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class MvcConfiig implements WebMvcConfigurer {

    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/**") // Apply to all endpoints
                .allowedOriginPatterns("*") // Allow all origins (or restrict to your ngrok URL)
                .allowedMethods("GET", "POST", "PUT", "DELETE", "OPTIONS") // Include OPTIONS!
                .allowedHeaders("*") // Allow all headers (or specify explicitly)
                .allowCredentials(false); // Set to true if using credentials (cookies, etc.)
    }
}
