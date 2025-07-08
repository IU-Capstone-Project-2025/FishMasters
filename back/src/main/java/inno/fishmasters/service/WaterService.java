package inno.fishmasters.service;

import inno.fishmasters.dto.request.water.WaterCreationRequest;
import inno.fishmasters.entity.Water;
import inno.fishmasters.exception.WaterIsNotFoundException;
import inno.fishmasters.repository.WaterRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class WaterService {
    private final WaterRepository waterRepository;

    public WaterService(WaterRepository waterRepository) {
        this.waterRepository = waterRepository;
    }

    public Water createWater(WaterCreationRequest request) {
        Water water = new Water(
                (long) (request.x() * 1000 + request.y()),
                request.x(),
                request.y()
        );
        return waterRepository.save(water);
    }

    public Water getWaterById(Long id) {
        return waterRepository.findById(id)
                .orElseThrow(() -> new WaterIsNotFoundException("Water not found with id: " + id));
    }

    public List<Water> getAllWaters() {
        return waterRepository.findAll();
    }
}
