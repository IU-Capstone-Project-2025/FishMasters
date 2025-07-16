package inno.fishmasters.dto.response;

import java.time.LocalDateTime;

public record MessageResponse(
        Long id,
        String content,
        String fisherEmail,
        LocalDateTime createdAt
) {
}
