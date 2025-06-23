package inno.fishmasters.service;

import inno.fishmasters.dto.request.fishing.FishingEventRequest;
import inno.fishmasters.entity.Fishing;
import inno.fishmasters.exception.FishingIsExistException;
import inno.fishmasters.repository.CaughtFishRepository;
import inno.fishmasters.repository.FishingRepository;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

@Service
public class FishingService {
    private final CaughtFishRepository caughtFishRepository;
    private final FishingRepository fishingRepository;

    public FishingService(CaughtFishRepository caughtFishRepository, FishingRepository fishingRepository) {
        this.caughtFishRepository = caughtFishRepository;
        this.fishingRepository = fishingRepository;
    }

    public Fishing startFishing(FishingEventRequest request) {
        Fishing fishing = new Fishing();
        fishing.setUserEmail(request.fisherEmail());
        fishing.setStartTime(LocalDateTime.now());
        fishing.setWater(request.water());
        return fishingRepository.save(fishing);
    }

    public Fishing endFishing(FishingEventRequest request) {
        Fishing fishing = fishingRepository.findByUserEmailAndWaterAndEndTimeIsNull(
                request.fisherEmail(), request.water()
        ).orElseThrow(() -> new FishingIsExistException("Active fishing session not found"));

        fishing.setEndTime(LocalDateTime.now());
        return fishingRepository.save(fishing);
    }
}
