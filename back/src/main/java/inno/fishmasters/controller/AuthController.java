package inno.fishmasters.controller;

import inno.fishmasters.dto.request.auth.CreateFisherRequest;
import inno.fishmasters.dto.request.auth.LoginFisherRequest;
import inno.fishmasters.entity.Fisher;
import inno.fishmasters.service.FisherService;
import io.swagger.v3.oas.annotations.Operation;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RequiredArgsConstructor
@RestController
@RequestMapping("/auth")
public class AuthController {

    private final FisherService fisherService;

    @Operation(summary = "Зарегистрировать рыбака")
    @PostMapping("/register")
    public ResponseEntity<Fisher> registerFisher(@RequestBody @Validated CreateFisherRequest request) {
        ;
        return ResponseEntity
                .status(200)
                .body(fisherService.register(request));
    }

    @Operation(summary = "Вход для рыбака")
    @PostMapping("/login")
    public ResponseEntity<Fisher> loginFisher(@RequestBody @Validated LoginFisherRequest request) {
        return ResponseEntity
                .status(200)
                .body(fisherService.login(request));
    }

}
