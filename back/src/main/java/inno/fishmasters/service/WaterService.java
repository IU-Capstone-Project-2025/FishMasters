package inno.fishmasters.service;

import inno.fishmasters.dto.request.water.WaterCreationRequest;
import inno.fishmasters.entity.Water;
import inno.fishmasters.repository.WaterRepository;
import org.springframework.stereotype.Service;

@Service
public class WaterService {
    private final WaterRepository waterRepository;

    public WaterService(WaterRepository waterRepository) {
        this.waterRepository = waterRepository;
    }

    public Water createWater(WaterCreationRequest request) {
        Water water = new Water();
        water.setX(request.x());
        water.setY(request.y());
        return waterRepository.save(water);
    }
}
