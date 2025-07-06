package inno.fishmasters.repository;

import inno.fishmasters.entity.Fisher;
import org.springframework.data.jpa.repository.JpaRepository;

public interface FisherRepository extends JpaRepository<Fisher, String> {
    Fisher findByEmail(String email);
    // Additional query methods can be defined here if needed
}
