package inno.fishmasters.dto.request.auth;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import org.springframework.web.multipart.MultipartFile;

@Schema(description = "Форма для создания пользователя")
public record CreateFisherRequest(
        @Email
        @NotNull
        @Size(max = 255, message = "Email не должен превышать 255 символов")
        String email,
        @NotNull
        @Size(max = 255, message = "Имя не должно превышать 255 символов")
        String name,
        @NotNull
        @Size(max = 255, message = "Фамилия не должно превышать 255 символов")
        String surname,
        @NotNull
        @Size(min = 6, max = 255, message = "Пароль должен быть от 6 до 255 символов")
        String password,
        MultipartFile photo
) {
}
