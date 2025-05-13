//package com.duel.masters.game.service;
//
//import com.duel.masters.game.config.unity.GameWebSocketHandler;
//import com.duel.masters.game.dto.GameStateDto;
//import com.duel.masters.game.dto.player.service.PlayerDto;
//import com.fasterxml.jackson.databind.ObjectMapper;
//import lombok.AllArgsConstructor;
//import lombok.extern.slf4j.Slf4j;
//import org.springframework.messaging.simp.SimpMessagingTemplate;
//import org.springframework.stereotype.Service;
//import org.springframework.web.socket.TextMessage;
//import org.springframework.web.socket.WebSocketSession;
//
//import java.util.List;
//import java.util.Timer;
//import java.util.TimerTask;
//import java.util.UUID;
//import java.util.concurrent.ThreadLocalRandom;
//
//import static com.duel.masters.game.constant.Constant.*;
//import static com.duel.masters.game.util.GameStateUtil.getGameStateDto;
//
//@Slf4j
//@Service
//@AllArgsConstructor
//public class GameService {
//
//    private final GameStateStore gameStateStore;
//    private final InitialStateService initialStateService;
//    private final MatchmakingService matchmakingService;
//    private final GameWebSocketHandler gameWebSocketHandler;
//    private final ObjectMapper objectMapper;
