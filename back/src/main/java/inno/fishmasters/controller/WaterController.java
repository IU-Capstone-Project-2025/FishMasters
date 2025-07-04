package inno.fishmasters.controller;

import inno.fishmasters.dto.request.water.WaterCreationRequest;
import inno.fishmasters.entity.Water;
import inno.fishmasters.service.WaterService;
import io.swagger.v3.oas.annotations.Operation;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/water")
public class WaterController {
    private final WaterService waterService;

    public WaterController(WaterService waterService) {
        this.waterService = waterService;
    }

    @Operation(summary = "Create a new water point")
    @PostMapping("/create")
    public ResponseEntity<Water> createWater(@Validated @RequestBody WaterCreationRequest request) {
        Water water = waterService.createWater(request);
        return ResponseEntity.ok(water);
    }
}

