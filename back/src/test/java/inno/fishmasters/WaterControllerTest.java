package inno.fishmasters;

import inno.fishmasters.controller.WaterController;
import inno.fishmasters.dto.request.water.WaterCreationRequest;
import inno.fishmasters.entity.Water;
import inno.fishmasters.service.WaterService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.http.ResponseEntity;
import org.springframework.test.context.bean.override.mockito.MockitoBean;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.Mockito.when;

@WebMvcTest(WaterController.class)
public class WaterControllerTest {

    @MockitoBean
    private WaterService waterService;

    @Autowired
    private WaterController waterController;

    @Test
    void shouldCreateNewWater() {
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

        ResponseEntity<Water> response = waterController.createWater(request);
        assertEquals(200, response.getStatusCode().value());
        assertEquals(water, response.getBody());
    }
}
