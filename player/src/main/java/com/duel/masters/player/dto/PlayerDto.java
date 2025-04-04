package com.duel.masters.player.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@AllArgsConstructor
@NoArgsConstructor
@Builder
@Data
public class PlayerDto {
    private Long id;
    @NotBlank(message = "Username is required")
    private String username;
    @NotBlank(message = "Password cannot be blank")
    @JsonProperty(access = JsonProperty.Access.WRITE_ONLY)
    private String password;
    @NotBlank(message = "Country must not be blank")
    private String country;
    private int victories;
    private int losses;
}
