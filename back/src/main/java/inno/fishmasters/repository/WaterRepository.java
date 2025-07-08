package inno.fishmasters.repository;

import inno.fishmasters.entity.Water;
import org.springframework.data.jpa.repository.JpaRepository;

public interface WaterRepository extends JpaRepository<Water, Double> {
}
