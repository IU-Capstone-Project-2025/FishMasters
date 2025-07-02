package inno.fishmasters.controller;

import inno.fishmasters.dto.request.fishing.CaughtFishRequest;
import inno.fishmasters.entity.CaughtFish;
import inno.fishmasters.service.CaughtFishService;
import io.swagger.v3.oas.annotations.Operation;
import lombok.AllArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

@AllArgsConstructor
@RestController
@RequestMapping("/api/caught-fish")
public class CaughtFishController {

    private final CaughtFishService caughtFishService;

    @Operation(summary = "Create a new caught fish",
            description = "Endpoint allows to create a new caught fish with optional photo")
    @PostMapping(consumes = {"multipart/form-data"})
    public ResponseEntity<CaughtFish> createCaughtFish(
            @RequestPart("data") CaughtFishRequest request,
            @RequestPart(value = "photo", required = false) MultipartFile photo
    ) {
        CaughtFish caughtFish = caughtFishService.createCaughtFish(request, photo);
        return ResponseEntity.ok(caughtFish);
    }
}

