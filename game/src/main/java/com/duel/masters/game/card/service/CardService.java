package com.duel.masters.game.card.service;

import com.duel.masters.game.card.mapper.CardMapper;
import com.duel.masters.game.card.repository.CardRepository;
import com.duel.masters.game.dto.card.service.CardDto;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.List;

@Slf4j
@Service
@AllArgsConstructor
public class CardService {
    private final CardRepository cardRepository;

    public List<CardDto> getDM01() {
        return cardRepository.findAll()
                .stream()
                .map(CardMapper::toCardDto)
                .toList();
    }
}
