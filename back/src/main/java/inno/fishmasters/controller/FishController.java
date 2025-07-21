package inno.fishmasters.controller;

import inno.fishmasters.entity.CaughtFish;
import inno.fishmasters.service.FishService;
import io.swagger.v3.oas.annotations.Operation;
import lombok.AllArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@AllArgsConstructor
@RequestMapping("/api/fish")
public class FishController {
    private final FishService fishService;

    @Operation(summary = "Get caught fishes by fishing id", description = "empty list if no fishes caught")
    @GetMapping("/caught/{fishingId}")
    public ResponseEntity<List<CaughtFish>> getCaughtFishByFishingId(@PathVariable Long fishingId) {
        List<CaughtFish> caughtFish = fishService.getCaughtFishByFishingId(fishingId);
        return ResponseEntity.ok(caughtFish);
    }
}
