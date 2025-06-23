package inno.fishmasters.repository;

import inno.fishmasters.entity.Fishing;
import org.springframework.data.jpa.repository.JpaRepository;

public interface FishingRepository extends JpaRepository<Fishing, Long> {

}
