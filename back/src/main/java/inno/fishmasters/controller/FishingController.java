package inno.fishmasters.controller;

import inno.fishmasters.dto.request.fishing.CaughtFishRequest;
import inno.fishmasters.dto.request.fishing.FishingEventRequest;
import inno.fishmasters.entity.CaughtFish;
import inno.fishmasters.entity.Fishing;
import inno.fishmasters.service.FishingService;
import io.swagger.v3.oas.annotations.Operation;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/fishing")
public class FishingController {
    private final FishingService fishingService;

    public FishingController(FishingService fishingService) {
        this.fishingService = fishingService;
    }

    @Operation(summary = "Start a new fishing session")
    @PostMapping("/start")
    public ResponseEntity<Fishing> startFishing(@RequestBody FishingEventRequest request) {
        Fishing fishing = fishingService.startFishing(request);
        return ResponseEntity.ok(fishing);
    }

    @Operation(summary = "End the current fishing session")
    @PostMapping("/end")
    public ResponseEntity<Fishing> endFishing(@RequestBody FishingEventRequest request) {
        Fishing fishing = fishingService.endFishing(request);
        return ResponseEntity.ok(fishing);
    }

    @Operation(summary = "Add a caught fish to the current fishing session",
               description = "Endpoint allows add a fish in current fishing session from fish database")
    @PostMapping("/add-caught-fish")
    public ResponseEntity<CaughtFish> addCaughtFish(@RequestBody CaughtFishRequest request) {
        CaughtFish caughtFish = fishingService.addCaughtFish(request);
        return ResponseEntity.ok(caughtFish);
    }

}
