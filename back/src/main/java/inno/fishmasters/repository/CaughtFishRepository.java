package inno.fishmasters.repository;

import inno.fishmasters.entity.CaughtFish;
import inno.fishmasters.entity.Fishing;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface CaughtFishRepository extends JpaRepository<CaughtFish, Long> {
    List<CaughtFish> findByFishing(Fishing fishing);
}
