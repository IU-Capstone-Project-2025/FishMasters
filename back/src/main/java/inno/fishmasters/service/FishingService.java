package inno.fishmasters.service;

import inno.fishmasters.entity.Fishing;
import inno.fishmasters.entity.Water;
import inno.fishmasters.repository.FishingRepository;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

@Service
public class FishingService {
    private final FishingRepository fishingRepository;

    public FishingService(FishingRepository fishingRepository) {
        this.fishingRepository = fishingRepository;
    }

    public Fishing startFishing(String userEmail, Water water) {
        Fishing fishing = new Fishing();
        fishing.setUserEmail(userEmail);
        fishing.setStartTime(LocalDateTime.now());
        fishing.setWater(water);
        return fishingRepository.save(fishing);
    }

    public Fishing endFishing(Long fishingId) {
        Fishing fishing = fishingRepository.findById(fishingId).orElseThrow(
                () -> new IllegalArgumentException("Fishing session not found with id: " + fishingId));
        fishing.setEndTime(LocalDateTime.now());
        return fishingRepository.save(fishing);
    }
}
