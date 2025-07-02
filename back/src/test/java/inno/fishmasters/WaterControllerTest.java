package inno.fishmasters;

import com.fasterxml.jackson.databind.ObjectMapper;
import inno.fishmasters.controller.WaterController;
import inno.fishmasters.dto.request.water.WaterCreationRequest;
import inno.fishmasters.entity.Water;
import inno.fishmasters.service.WaterService;
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

@WebMvcTest(WaterController.class)
public class WaterControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockitoBean
    private WaterService waterService;

    @Autowired
    private ObjectMapper objectMapper;

    @Test
    void shouldCreateNewWater() throws Exception {
        WaterCreationRequest request = new WaterCreationRequest(
                0.5,
                0.5
        );
        Water water = new Water(
                1L,
                0.5,
                0.5
        );
        when(waterService.createWater(request)).thenReturn(water);

        mockMvc.perform(post("/api/water/create")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(1L))
                .andExpect(jsonPath("$.x").value(0.5))
                .andExpect(jsonPath("$.y").value(0.5));
    }
}
