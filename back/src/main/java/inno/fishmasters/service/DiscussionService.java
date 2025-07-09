package inno.fishmasters.service;

import inno.fishmasters.entity.Discussion;
import inno.fishmasters.entity.Water;
import inno.fishmasters.repository.DiscussionRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.log4j.Log4j2;
import org.springframework.stereotype.Service;

@Log4j2
@Service
@RequiredArgsConstructor
public class DiscussionService {

    private final DiscussionRepository discussionRepository;
    private final WaterService waterService;

    public Discussion createDiscussion(Double waterId) {
        Water water = waterService.getWaterById(waterId);
        Discussion discussion = discussionRepository.getDiscussionByWater(water);
        if (discussion != null) {
            log.warn("Discussion already exists for water with id: {}", waterId);
            return discussion;

        }
        discussion = new Discussion();
        discussion.setWater(waterService.getWaterById(waterId));
        return discussionRepository.save(discussion);
    }

}
