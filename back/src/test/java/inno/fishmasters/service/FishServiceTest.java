package inno.fishmasters.service;

import inno.fishmasters.dto.request.fishing.CaughtFishRequest;
import inno.fishmasters.entity.CaughtFish;
import inno.fishmasters.entity.Fish;
import inno.fishmasters.entity.Fishing;
import inno.fishmasters.exception.FishIsExistException;
import inno.fishmasters.exception.FishingIsNotExistException;
import inno.fishmasters.repository.CaughtFishRepository;
import inno.fishmasters.repository.FishRepository;
import inno.fishmasters.repository.FishingRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.*;
import java.time.LocalDateTime;
import java.util.*;

import static org.assertj.core.api.Assertions.*;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.Mockito.*;

class FishServiceTest {

    @Mock
    private CaughtFishRepository caughtFishRepository;

    @Mock
    private FishRepository fishRepository;

    @Mock
    private FishingRepository fishingRepository;

    @InjectMocks
    private FishService fishService;

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
    }

    @Test
    void addCaughtFish_successfully() {
        Long fishingId = 1L;
        Long fishId = 2L;
        double weight = 1.5;
        String fisherEmail = "user@mail.com";

        CaughtFishRequest request = new CaughtFishRequest (fishingId, fishId, weight, "photo");

        Fishing fishing = new Fishing();
        fishing.setId(fishingId);
        fishing.setUserEmail(fisherEmail);
        fishing.setStartTime(LocalDateTime.now());

        Fish fish = new Fish();
        fish.setId(fishId);

        CaughtFish expectedCaught = new CaughtFish();
        expectedCaught.setFish(fish);
        expectedCaught.setFishing(fishing);
        expectedCaught.setAvgWeight(weight);
        expectedCaught.setFisher(fisherEmail);

        when(fishingRepository.findById(fishingId)).thenReturn(Optional.of(fishing));
        when(fishRepository.findById(fishId)).thenReturn(Optional.of(fish));
        when(caughtFishRepository.save(any())).thenReturn(expectedCaught);

        CaughtFish actual = fishService.addCaughtFish(request);

        assertThat(actual.getFish()).isEqualTo(fish);
        assertThat(actual.getFishing()).isEqualTo(fishing);
        assertThat(actual.getFisher()).isEqualTo(fisherEmail);
        assertThat(actual.getAvgWeight()).isEqualTo(weight);

        verify(caughtFishRepository).save(any());
    }

    @Test
    void addCaughtFish_shouldThrow_whenFishingNotFound() {
        CaughtFishRequest request = new CaughtFishRequest(1L, 2L, 1.5, "photo");

        when(fishingRepository.findById(1L)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> fishService.addCaughtFish(request))
                .isInstanceOf(FishingIsNotExistException.class)
                .hasMessageContaining("Fishing session not found");
    }

    @Test
    void addCaughtFish_shouldThrow_whenFishingEnded() {
        Fishing fishing = new Fishing();
        fishing.setId(1L);
        fishing.setEndTime(LocalDateTime.now());

        CaughtFishRequest request = new CaughtFishRequest(1L, 2L, 1.5, "photo");

        when(fishingRepository.findById(1L)).thenReturn(Optional.of(fishing));

        assertThatThrownBy(() -> fishService.addCaughtFish(request))
                .isInstanceOf(FishingIsNotExistException.class)
                .hasMessageContaining("Fishing session has already ended");
    }

    @Test
    void addCaughtFish_shouldThrow_whenFishNotFound() {
        Fishing fishing = new Fishing();
        fishing.setId(1L);
        fishing.setStartTime(LocalDateTime.now());
        fishing.setUserEmail("user@mail.com");

        CaughtFishRequest request = new CaughtFishRequest(1L, 2L, 1.5, "photo");

        when(fishingRepository.findById(1L)).thenReturn(Optional.of(fishing));
        when(fishRepository.findById(2L)).thenReturn(Optional.empty());

        assertThrows(FishIsExistException.class, () -> fishService.addCaughtFish(request));

    }

    @Test
    void getCaughtFishByFishingId_successfully() {
        Long fishingId = 1L;
        Fishing fishing = new Fishing();
        fishing.setId(fishingId);

        CaughtFish caught1 = new CaughtFish();
        CaughtFish caught2 = new CaughtFish();

        List<CaughtFish> fishList = List.of(caught1, caught2);

        when(fishingRepository.findById(fishingId)).thenReturn(Optional.of(fishing));
        when(caughtFishRepository.findByFishing(fishing)).thenReturn(fishList);

        List<CaughtFish> result = fishService.getCaughtFishByFishingId(fishingId);

        assertThat(result).hasSize(2);
        verify(fishingRepository).findById(fishingId);
        verify(caughtFishRepository).findByFishing(fishing);
    }

    @Test
    void getCaughtFishByFishingId_shouldThrow_whenFishingNotFound() {
        when(fishingRepository.findById(1L)).thenReturn(Optional.empty());

        assertThrows(FishingIsNotExistException.class, () -> fishService.getCaughtFishByFishingId(1L));
    }

}
