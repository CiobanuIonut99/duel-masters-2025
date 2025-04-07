package com.duel.masters.card.service;

import com.duel.masters.card.dto.CardDto;
import com.duel.masters.card.mapper.CardMapper;
import com.duel.masters.card.repository.CardRepository;
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
