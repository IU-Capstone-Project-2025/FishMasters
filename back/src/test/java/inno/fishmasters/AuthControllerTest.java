package inno.fishmasters;

import inno.fishmasters.controller.AuthController;
import inno.fishmasters.dto.request.auth.CreateFisherRequest;
import inno.fishmasters.entity.Fisher;
import inno.fishmasters.service.FisherService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.http.ResponseEntity;
import org.springframework.test.context.bean.override.mockito.MockitoBean;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.Mockito.when;

@WebMvcTest(AuthController.class)
public class AuthControllerTest {

    @MockitoBean
    private FisherService fisherService;

    @Autowired
    private AuthController authController;


    @Test
    void shouldRegisterNewFisher() {
        CreateFisherRequest request = new CreateFisherRequest(
                "test@mail.com",
                "Name",
                "Surname",
                "password",
                null
        );
        Fisher fisher = new Fisher(
                "test@mail.com",
                "Name",
                "Surname",
                "password",
                0,
                null);

        when(fisherService.register(request)).thenReturn(fisher);

        ResponseEntity<Fisher> response = authController.registerFisher(request);

        assertEquals(200, response.getStatusCode().value());
        assertEquals(fisher, response.getBody());
    }
}
