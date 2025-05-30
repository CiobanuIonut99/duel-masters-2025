package com.duel.masters.gateway;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.slf4j.MDC;
import org.springframework.cloud.gateway.filter.GatewayFilterChain;
import org.springframework.cloud.gateway.filter.GlobalFilter;
import org.springframework.core.Ordered;
import org.springframework.http.server.reactive.ServerHttpRequest;
import org.springframework.stereotype.Component;
import org.springframework.web.server.ServerWebExchange;
import reactor.core.publisher.Mono;

import java.util.UUID;

@Component
public class TraceIdFilter implements GlobalFilter, Ordered {

    private static final Logger logger = LoggerFactory.getLogger(TraceIdFilter.class);

    @Override
    public Mono<Void> filter(ServerWebExchange exchange, GatewayFilterChain chain) {
        String traceId = UUID.randomUUID().toString();
        ServerHttpRequest mutatedRequest = exchange.getRequest()
                .mutate()
                .header("X-Trace-Id", traceId)
                .build();

        // Log in gateway logs with MDC
        MDC.put("traceId", traceId);

        logger.info("Incoming request: {} with traceId={}", exchange.getRequest().getURI(), traceId);

        return chain.filter(exchange.mutate().request(mutatedRequest).build())
                .doFinally(signal -> MDC.clear());
    }

    @Override
    public int getOrder() {
        return -1;
    }

}
