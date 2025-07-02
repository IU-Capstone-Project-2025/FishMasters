package inno.fishmasters.dto.request.fishing;

import jakarta.validation.constraints.NotNull;

public record CaughtFishRequest(
        @NotNull
        Long fishingId,
        Long fishId,
        Double weight,
        String fisherEmail
) {
}
