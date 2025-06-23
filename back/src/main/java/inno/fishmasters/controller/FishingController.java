package inno.fishmasters.controller;

import inno.fishmasters.dto.request.fishing.FishingEventRequest;
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
        Fishing fishing = fishingService.startFishing(request.fisherEmail(), request.water());
        return ResponseEntity.ok(fishing);
    }

    @PostMapping("/end/{fishingId}")
    public ResponseEntity<Fishing> endFishing(@PathVariable Long fishingId) {
        Fishing fishing = fishingService.endFishing(fishingId);
        return ResponseEntity.ok(fishing);
    }

}
