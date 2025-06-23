package inno.fishmasters.repository;

import inno.fishmasters.entity.Fishing;
import inno.fishmasters.entity.Water;
import jakarta.validation.constraints.NotNull;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface FishingRepository extends JpaRepository<Fishing, Long> {
    Optional<Fishing> findByUserEmailAndWaterAndEndTimeIsNull(String fisherEmail, Water water);

    Optional<Fishing> findByIdAndEndTimeIsNull(@NotNull Long aLong);
}
