package inno.fishmasters.controller;

import inno.fishmasters.dto.request.auth.CreateFisherRequest;
import inno.fishmasters.dto.request.auth.LoginFisherRequest;
import inno.fishmasters.entity.Fisher;
import inno.fishmasters.service.FisherService;
import io.swagger.v3.oas.annotations.Operation;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

@RequiredArgsConstructor
@RestController
@RequestMapping("/auth")
public class AuthController {

    private final FisherService fisherService;

    @Operation(summary = "Register a new fisher")
    @PostMapping("/register")
    public ResponseEntity<Fisher> registerFisher(@RequestBody @Validated CreateFisherRequest request) {
        return ResponseEntity
                .status(200)
                .body(fisherService.register(request));
    }

    @Operation(summary = "Login an existing fisher")
    @PostMapping("/login")
    public ResponseEntity<Fisher> loginFisher(@RequestBody @Validated LoginFisherRequest request) {
        return ResponseEntity
                .status(200)
                .body(fisherService.login(request));
    }

    @Operation(summary = "Update fisher photo")
    @PostMapping(value = "/update-photo", consumes = "multipart/form-data")
    public ResponseEntity<Fisher> uploadFisherPhoto(
            @RequestParam("email") String email,
            @RequestPart("photo") MultipartFile photo
    ) {
        Fisher fisher = fisherService.updateFisherPhoto(email, photo);
        return ResponseEntity.ok(fisher);
    }

}
