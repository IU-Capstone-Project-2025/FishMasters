package inno.fishmasters.dto.response;

import inno.fishmasters.entity.Water;

public record FishingEventResponse(
        String fisherEmail,
        Water water
) {
}
