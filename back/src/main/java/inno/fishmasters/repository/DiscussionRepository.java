package inno.fishmasters.repository;

import inno.fishmasters.entity.Discussion;
import inno.fishmasters.entity.Water;
import org.springframework.data.jpa.repository.JpaRepository;

public interface DiscussionRepository extends JpaRepository<Discussion, Long> {
    Discussion getDiscussionByWater(Water water);
}
