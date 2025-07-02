package inno.fishmasters.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import inno.fishmasters.dto.request.auth.CreateFisherRequest;
import inno.fishmasters.dto.request.auth.LoginFisherRequest;
import inno.fishmasters.entity.Fisher;
import inno.fishmasters.service.FisherService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(AuthController.class)
public class AuthControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockitoBean
    private FisherService fisherService;

    @Autowired
    private ObjectMapper objectMapper;


    @Test
    void shouldRegisterNewFisher() throws Exception {
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

        mockMvc.perform(post("/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.email").value("test@mail.com"))
                .andExpect(jsonPath("$.name").value("Name"));
    }

    @Test
    void shouldLoginExistingFisher() throws Exception {
        LoginFisherRequest request = new LoginFisherRequest(
                "test@mail.com",
                "password"
        );

        Fisher fisher = new Fisher(
                "test@mail.com",
                "Name",
                "Surname",
                "password",
                0,
                null
        );

        when(fisherService.login(request)).thenReturn(fisher);
        mockMvc.perform(post("/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.email").value("test@mail.com"));
    }
}
