package inno.fishmasters.dto.request.fishing;

import inno.fishmasters.entity.Water;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotNull;


@Schema(description = "Запрос на создание события рыбалки")
public record FishingEventRequest(
        @Email
        @NotNull
        String fisherEmail,
        @NotNull
        Water water
) {
}