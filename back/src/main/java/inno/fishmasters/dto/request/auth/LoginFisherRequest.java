package inno.fishmasters.dto.request.auth;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

@Schema(description = "Форма для создания пользователя")
public record LoginFisherRequest(
        @Email
        @NotNull
        @Size(max = 255, message = "Email не должен превышать 255 символов")
        String email,
        @NotNull
        @Size(min = 6, max = 255, message = "Пароль должен быть от 6 до 255 символов")
        String password
) {
}