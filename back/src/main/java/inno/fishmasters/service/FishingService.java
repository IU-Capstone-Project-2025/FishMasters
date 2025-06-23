package inno.fishmasters.service;

import inno.fishmasters.dto.request.fishing.CaughtFishRequest;
import inno.fishmasters.dto.request.fishing.FishingEventRequest;
import inno.fishmasters.entity.CaughtFish;
import inno.fishmasters.entity.Fish;
import inno.fishmasters.entity.Fishing;
import inno.fishmasters.exception.FishIsExistException;
import inno.fishmasters.exception.FishingIsExistException;
import inno.fishmasters.repository.CaughtFishRepository;
import inno.fishmasters.repository.FishRepository;
import inno.fishmasters.repository.FishingRepository;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

@Service
public class FishingService {
    private final CaughtFishRepository caughtFishRepository;
    private final FishingRepository fishingRepository;
    private final FishRepository fishRepository;

    public FishingService(CaughtFishRepository caughtFishRepository, FishingRepository fishingRepository,
                          FishRepository fishRepository) {
        this.caughtFishRepository = caughtFishRepository;
        this.fishingRepository = fishingRepository;
        this.fishRepository = fishRepository;
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

    public CaughtFish addCaughtFish(CaughtFishRequest request) {
        Fishing fishing = fishingRepository.findByIdAndEndTimeIsNull(request.fishingId())
                .orElseThrow(() -> new FishingIsExistException("Fishing session not found"));

        Fish fish = fishRepository.findById(request.fishId())
                .orElseThrow(() -> new FishIsExistException("Fish not found"));

        CaughtFish caughtFish = new CaughtFish();
        caughtFish.setFishing(fishing);
        caughtFish.setFish(fish);
        caughtFish.setAvgWeight(request.weight());
        caughtFish.setFisher(fishing.getUserEmail());

        return caughtFishRepository.save(caughtFish);
    }
}
