package com.duel.masters.game.config.unity;

import lombok.AllArgsConstructor;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.socket.config.annotation.EnableWebSocket;
import org.springframework.web.socket.config.annotation.WebSocketConfigurer;
import org.springframework.web.socket.config.annotation.WebSocketHandlerRegistry;

@Configuration
@EnableWebSocket
@AllArgsConstructor
public class WebSocketServerConfig implements WebSocketConfigurer {
    private final GameWebSocketHandler gameWebSocketHandler;


    @Override
    public void registerWebSocketHandlers(WebSocketHandlerRegistry registry) {
        registry
                .addHandler(gameWebSocketHandler,
                        "/duel-masters-ws")
                .setAllowedOriginPatterns("*");
    }
}
