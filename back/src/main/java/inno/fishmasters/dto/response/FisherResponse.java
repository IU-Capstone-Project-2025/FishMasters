package inno.fishmasters.dto.response;

public record FisherResponse(
        String email,
        String name,
        String surname,
        String password,
        int score,
        byte[] photo
) {
}
