package com.duel.masters.card.entity;

import com.duel.masters.card.enums.Civilization;
import com.duel.masters.card.enums.SpecialAbility;
import com.duel.masters.card.enums.Type;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@AllArgsConstructor
@NoArgsConstructor
@Builder
@Data
public class Card {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String name;
    @Enumerated(EnumType.STRING)
    private Type type;
    @Enumerated(EnumType.STRING)
    private Civilization civilization;
    private String race;
    private int manaCost;
    private int manaNumber;
    private int power;
    private String ability;
    private String raritySymbol;
    @Enumerated(EnumType.STRING)
    private SpecialAbility specialAbility;

}
