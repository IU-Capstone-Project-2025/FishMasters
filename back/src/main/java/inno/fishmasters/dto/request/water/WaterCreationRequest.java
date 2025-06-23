package inno.fishmasters.dto.request.water;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotNull;

@Schema(description = "Запрос на создание водоема")
public record WaterCreationRequest(
        @NotNull
        double x,
        @NotNull
        double y
) {
}
