package inno.fishmasters.repository;

import inno.fishmasters.entity.CaughtFish;
import org.springframework.data.jpa.repository.JpaRepository;

public interface CaughtFishRepository extends JpaRepository<CaughtFish, Long> {
}
