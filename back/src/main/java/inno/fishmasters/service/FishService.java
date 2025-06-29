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
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.List;

@Slf4j
@Service
@AllArgsConstructor
public class FishService {

    private final CaughtFishRepository caughtFishRepository;
    private final FishRepository fishRepository;
    private final FishingRepository fishingRepository;


    public CaughtFish addCaughtFish(CaughtFishRequest request) {
        log.info("fishing id is {}", request.fishingId());
        Fishing fishing = fishingRepository.findById(request.fishingId())
                .orElseThrow(() -> new FishingIsNotExistException("Fishing session not found"));

        if (fishing.getEndTime() != null) {
            throw new FishingIsNotExistException("Fishing session has already ended");
        }

        Fish fish = fishRepository.findById(request.fishId())
                .orElseThrow(() -> new FishIsExistException("Fish not found"));

        CaughtFish caughtFish = new CaughtFish();
        caughtFish.setFishing(fishing);
        caughtFish.setFish(fish);
        caughtFish.setAvgWeight(request.weight());
        caughtFish.setFisher(fishing.getUserEmail());

        return caughtFishRepository.save(caughtFish);
    }

    public List<CaughtFish> getCaughtFishByFishingId(Long fishingId) {
        Fishing fishing = fishingRepository.findById(fishingId)
                .orElseThrow(() -> new FishingIsNotExistException("Fishing session not found"));
        return caughtFishRepository.findByFishing(fishing);
    }
}
