package inno.fishmasters.controller;

import inno.fishmasters.dto.request.fishing.CaughtFishRequest;
import inno.fishmasters.dto.request.fishing.FishingEventRequest;
import inno.fishmasters.entity.CaughtFish;
import inno.fishmasters.entity.Fishing;
import inno.fishmasters.service.FishingService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/fishing")
public class FishingController {
    private final FishingService fishingService;

    public FishingController(FishingService fishingService) {
        this.fishingService = fishingService;
    }

    @PostMapping("/start")
    public ResponseEntity<Fishing> startFishing(@RequestBody FishingEventRequest request) {
        Fishing fishing = fishingService.startFishing(request);
        return ResponseEntity.ok(fishing);
    }

    @PostMapping("/end")
    public ResponseEntity<Fishing> endFishing(@RequestBody FishingEventRequest request) {
        Fishing fishing = fishingService.endFishing(request);
        return ResponseEntity.ok(fishing);
    }

    @PostMapping("/add-caught-fish")
    public ResponseEntity<CaughtFish> addCaughtFish(@RequestBody CaughtFishRequest request) {
        CaughtFish caughtFish = fishingService.addCaughtFish(request);
        return ResponseEntity.ok(caughtFish);
    }

}
