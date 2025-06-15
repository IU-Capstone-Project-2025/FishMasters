package inno.fishmasters.controller;

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

    @Operation(summary = "Добавить пользователя")
    @PostMapping("/create")
    public ResponseEntity<String> addUser(@RequestBody @Validated CreateUserRequest request) {
        userService.create(request);
        return ResponseEntity.ok("Пользователь успешно добавлен");
    }

}
