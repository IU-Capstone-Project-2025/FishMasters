package inno.fishmasters.controller;

import inno.fishmasters.entity.Fisher;
import inno.fishmasters.service.FisherService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

import java.util.Arrays;
import java.util.List;

import static org.hamcrest.Matchers.hasSize;
import static org.hamcrest.Matchers.is;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(LeaderboardController.class)
class LeaderboardControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockitoBean
    private FisherService fisherService;

    @Test
    void shouldFindBothFisher() throws Exception {
        List<Fisher> topFishers = Arrays.asList(
                new Fisher(
                        "test1@mail.com",
                        "test1",
                        "test1",
                        "qwerty0000",
                        5,
                        null),
                new Fisher(
                        "test2@mail.com",
                        "test2",
                        "test2",
                        "qwerty0000",
                        0,
                        null)
        );

        when(fisherService.getTopFishers(2)).thenReturn(topFishers);

        mockMvc.perform(get("/api/leaderboard/top?count=2"))
                .andExpect(status().isOk())
                .andExpect(content().contentType(MediaType.APPLICATION_JSON))
                .andExpect(jsonPath("$", hasSize(2)))
                .andExpect(jsonPath("$[0].email", is("test1@mail.com")))
                .andExpect(jsonPath("$[0].name", is("test1")))
                .andExpect(jsonPath("$[0].score", is(5)))
                .andExpect(jsonPath("$[1].name", is("test2")));
    }

    @Test
    void shouldFindAllFisher() throws Exception {
        List<Fisher> allFishers = Arrays.asList(
                new Fisher(
                        "test1@mail.com",
                        "test1",
                        "test1",
                        "qwerty0000",
                        0,
                        null),
                new Fisher(
                        "test2@mail.com",
                        "test2",
                        "test2",
                        "qwerty0000",
                        0,
                        null)
        );

        when(fisherService.getAllFishers()).thenReturn(allFishers);

        mockMvc.perform(get("/api/leaderboard/all"))
                .andExpect(status().isOk())
                .andExpect(content().contentType(MediaType.APPLICATION_JSON))
                .andExpect(jsonPath("$", hasSize(2)))
                .andExpect(jsonPath("$[0].name", is("test1")))
                .andExpect(jsonPath("$[1].name", is("test2")));
    }
}
