package inno.fishmasters.controller;

import inno.fishmasters.dto.request.fishing.CaughtFishRequest;
import inno.fishmasters.entity.CaughtFish;
import inno.fishmasters.service.FishService;
import io.swagger.v3.oas.annotations.Operation;
import lombok.AllArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@AllArgsConstructor
@RequestMapping("/api/fish")
public class FishController {
    private final FishService fishService;

    @Operation(summary = "Add a caught fish to the current fishing session",
            description = "Endpoint allows add a fish in current fishing session from fish database")
    @PostMapping("/add-caught-fish")
    public ResponseEntity<CaughtFish> addCaughtFish(@Validated @RequestBody CaughtFishRequest request) {
        CaughtFish caughtFish = fishService.addCaughtFish(request);
        return ResponseEntity.ok(caughtFish);
    }

    @Operation(summary = "Get caught fishes by fishing id", description = "empty list if no fishes caught")
    @GetMapping("/caught/{fishingId}")
    public ResponseEntity<List<CaughtFish>> getCaughtFishByFishingId(@PathVariable Long fishingId) {
        List<CaughtFish> caughtFish = fishService.getCaughtFishByFishingId(fishingId);
        return ResponseEntity.ok(caughtFish);
    }
}
