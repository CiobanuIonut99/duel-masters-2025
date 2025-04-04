package com.duel.masters.player.aspect;

import lombok.extern.slf4j.Slf4j;
import org.aspectj.lang.JoinPoint;
import org.aspectj.lang.annotation.After;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Before;
import org.aspectj.lang.annotation.Pointcut;
import org.springframework.stereotype.Component;

@Component
@Slf4j
@Aspect
public class LoggingAspect {
    @Pointcut("within(@org.springframework.web.bind.annotation.RestController *)")
    public void pointcut() {
    }

    @Before("pointcut()")
    public void before(JoinPoint joinPoint) {
        log("Started process");
        log.info("Entered: {}.{} with parameters: {}",
                joinPoint.getSignature().getDeclaringType().getSimpleName(),
                joinPoint.getSignature().getName(),
                joinPoint.getArgs());
    }

    @After("pointcut()")
    public void after(JoinPoint joinPoint) {
        log.info("Finished: {}.{}",
                joinPoint.getSignature().getDeclaringType().getSimpleName(),
                joinPoint.getSignature().getName());
        log("Ended process");
    }

    private static void log(String message) {
        log.info("-".repeat(50));
        log.info(message);
        log.info("-".repeat(50));
    }
}
