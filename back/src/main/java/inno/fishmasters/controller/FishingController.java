package inno.fishmasters.controller;

import inno.fishmasters.dto.request.fishing.FishingEventRequest;
import inno.fishmasters.entity.Fishing;
import inno.fishmasters.service.FishingService;
import io.swagger.v3.oas.annotations.Operation;
import lombok.AllArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@AllArgsConstructor
@RequestMapping("/api/fishing")
public class   FishingController {
    private final FishingService fishingService;

    @Operation(summary = "Start a new fishing session")
    @PostMapping("/start")
    public ResponseEntity<Fishing> startFishing(@Validated @RequestBody FishingEventRequest request) {
        Fishing fishing = fishingService.startFishing(request);
        return ResponseEntity.ok(fishing);
    }

    @Operation(summary = "End the current fishing session")
    @PostMapping("/end")
    public ResponseEntity<Fishing> endFishing(@Validated @RequestBody FishingEventRequest request) {
        Fishing fishing = fishingService.endFishing(request);
        return ResponseEntity.ok(fishing);
    }

    @GetMapping("/{fishingId}")
    @Operation(summary = "Get fishing session by ID", description = "fishingId is a path variable")
    public ResponseEntity<Fishing> getFishingById(@PathVariable Long fishingId) {
        Fishing fishing = fishingService.getFishingById(fishingId);
        return ResponseEntity.ok(fishing);
    }

    @GetMapping("/{fisherEmail}")
    @Operation(summary = "Get all fishings by fisher email", description = "fisherEmail is a path variable")
    public ResponseEntity<List<Fishing>> getFishingsByFisherEmail(@PathVariable String fisherEmail) {
        List<Fishing> fishings = fishingService.getFishingsByFisherEmail(fisherEmail);
        return ResponseEntity.ok(fishings);
    }
}
