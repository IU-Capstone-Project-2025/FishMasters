package inno.fishmasters.service;

import inno.fishmasters.dto.request.fishing.CaughtFishRequest;
import inno.fishmasters.entity.CaughtFish;
import inno.fishmasters.entity.Fish;
import inno.fishmasters.entity.Fishing;
import inno.fishmasters.repository.CaughtFishRepository;
import inno.fishmasters.repository.FishRepository;
import inno.fishmasters.repository.FishingRepository;
import lombok.AllArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

@AllArgsConstructor
@Service
public class CaughtFishService {

    private final CaughtFishRepository caughtFishRepository;
    private final FishingRepository fishingRepository;
    private final FishRepository fishRepository;

    public CaughtFish createCaughtFish(CaughtFishRequest request, MultipartFile photo) {
        Fishing fishing = fishingRepository.findById(request.fishingId())
                .orElseThrow(() -> new IllegalArgumentException("Fishing event not found"));
        Fish fish = fishRepository.findById(request.fishId())
                .orElseThrow(() -> new IllegalArgumentException("Fish type not found"));
        CaughtFish caughtFish = new CaughtFish();
        caughtFish.setFisher(request.fisherEmail());
        caughtFish.setAvgWeight(request.weight());
        caughtFish.setFishing(fishing);
        caughtFish.setFish(fish);
        if (photo != null && !photo.isEmpty()) {
            try {
                caughtFish.setPhoto(photo.getBytes());
            } catch (Exception e) {
                throw new RuntimeException("Failed to read photo bytes", e);
            }
        }
        return caughtFishRepository.save(caughtFish);
    }


}
