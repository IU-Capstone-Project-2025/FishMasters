package inno.fishmasters.repository;

import inno.fishmasters.entity.Discussion;
import inno.fishmasters.entity.Message;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface MessageRepository extends JpaRepository<Message, Long> {
    List<Message> findAllByDiscussion(Discussion discussion);
}
