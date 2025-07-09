package inno.fishmasters.repository;

import inno.fishmasters.entity.Fisher;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface FisherRepository extends JpaRepository<Fisher, String> {
    Fisher findByEmail(String email);

    List<Fisher> findAllByOrderByScoreDesc(Pageable pageable);

    List<Fisher> findAllByOrderByScoreDesc();
}
