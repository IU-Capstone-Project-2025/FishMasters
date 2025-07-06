package inno.fishmasters.service;

import inno.fishmasters.dto.request.fishing.FishingEventRequest;
import inno.fishmasters.entity.Fishing;
import inno.fishmasters.exception.FishingIsNotExistException;
import inno.fishmasters.repository.FishingRepository;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Slf4j
@AllArgsConstructor
@Service
public class FishingService {
    private final FishingRepository fishingRepository;

    public Fishing startFishing(FishingEventRequest request) {
        Fishing fishing = new Fishing();
        fishing.setUserEmail(request.fisherEmail());
        fishing.setStartTime(LocalDateTime.now());
        fishing.setWater(request.water());
        return fishingRepository.save(fishing);
    }

    //TODO: maybe get fishing also by id as in addCaughtFish method
    public Fishing endFishing(FishingEventRequest request) {
        Fishing fishing = fishingRepository
                .findByUserEmailAndWaterAndEndTimeIsNull(request.fisherEmail(), request.water())
                .orElseThrow(() -> new FishingIsNotExistException("Active fishing session not found"));

        fishing.setEndTime(LocalDateTime.now());
        return fishingRepository.save(fishing);
    }

    public Fishing getFishingById(Long fishingId) {
        return fishingRepository.findById(fishingId)
                .orElseThrow(() -> new FishingIsNotExistException("Fishing session not found"));
    }

    public List<Fishing> getFishingsByFisherEmail(String fisherEmail) {
        return fishingRepository.getFishingsByUserEmail(fisherEmail);
    }
}
