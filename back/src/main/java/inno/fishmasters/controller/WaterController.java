package inno.fishmasters.controller;

import inno.fishmasters.dto.request.water.WaterCreationRequest;
import inno.fishmasters.entity.Water;
import inno.fishmasters.service.WaterService;
import io.swagger.v3.oas.annotations.Operation;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/water")
public class WaterController {
    private final WaterService waterService;

    public WaterController(WaterService waterService) {
        this.waterService = waterService;
    }

    @Operation(summary = "Create a new water point", description = "ID of water is computed by formula: x * 1000 + y")
    @PostMapping("/create")
    public ResponseEntity<Water> createWater(@Validated @RequestBody WaterCreationRequest request) {
        Water water = waterService.createWater(request);
        return ResponseEntity.ok(water);
    }

    @Operation(summary = "Get water point by coordinates")
    @GetMapping("/{id}")
    public ResponseEntity<Water> getWaterById(@PathVariable Double id) {
        Water water = waterService.getWaterById(id);
        return ResponseEntity.ok(water);
    }

    @Operation(summary = "Get all water points")
    @GetMapping("/all")
    public ResponseEntity<List<Water>> getAllWaters() {
        List<Water> waters = waterService.getAllWaters();
        return ResponseEntity.ok(waters);
    }
}

