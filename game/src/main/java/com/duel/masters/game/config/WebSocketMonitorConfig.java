//package com.duel.masters.game.config;
//
//import lombok.extern.slf4j.Slf4j;
//import org.springframework.context.annotation.Configuration;
//import org.springframework.messaging.Message;
//import org.springframework.messaging.MessageChannel;
//import org.springframework.messaging.simp.config.ChannelRegistration;
//import org.springframework.messaging.simp.stomp.StompHeaderAccessor;
//import org.springframework.messaging.support.ChannelInterceptor;
//import org.springframework.web.socket.config.annotation.WebSocketMessageBrokerConfigurer;
//
//@Configuration
//@Slf4j
//public class WebSocketMonitorConfig implements WebSocketMessageBrokerConfigurer {
//
//    @Override
//    public void configureClientInboundChannel(ChannelRegistration registration) {
//        registration.interceptors(new HeartbeatLoggingInterceptor());
//    }
//
//    static class HeartbeatLoggingInterceptor implements ChannelInterceptor {
//        @Override
//        public Message<?> preSend(Message<?> message, MessageChannel channel) {
//            StompHeaderAccessor accessor = StompHeaderAccessor.wrap(message);
//
//            if (accessor.getCommand() == null) {
//                // Heartbeats are "empty" messages with no STOMP command
//                log.info("📡 Heartbeat received from session: {}", accessor.getSessionId());
//            }
//
//            return message;
//        }
//    }
//}
