package inno.fishmasters.service;

import inno.fishmasters.dto.request.auth.CreateFisherRequest;
import inno.fishmasters.dto.request.auth.LoginFisherRequest;
import inno.fishmasters.entity.Fisher;
import inno.fishmasters.exception.FisherIsExistException;
import inno.fishmasters.repository.FisherRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.log4j.Log4j2;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

@Log4j2
@Service
@RequiredArgsConstructor
public class FisherService {

    //TODO: realize password encryption and validation for all fields

    private final FisherRepository fisherRepository;

    /**
     * Register a new fisher
     *
     * @param request CreateFisherRequest containing fisher details
     * @return Fisher entity
     * @throws FisherIsExistException if a fisher with the same email already exists
     */
    public Fisher register(CreateFisherRequest request) {
        if (fisherRepository.existsById(request.email())) {
            throw new FisherIsExistException("Fisher with email " + request.email() + " already exists");
        } else {
            return fisherRepository.save(new Fisher(
                    request.email(),
                    request.name(),
                    request.surname(),
                    request.password(),
                    0, // initial score starts at 0
                    null // without photo for now
            ));
        }
    }

    /**
     * Login a fisher
     *
     * @param request LoginFisherRequest containing fisher email and password
     * @return Fisher entity if login is successful
     * @throws IllegalArgumentException if password is incorrect
     */
    public Fisher login(LoginFisherRequest request) {
        Fisher fisher = fisherRepository.findById(request.email())
                .orElseThrow(() -> new FisherIsExistException("Fisher with email " + request.email() + " does not exist"));

        if (!fisher.getPassword().equals(request.password())) {
            throw new IllegalArgumentException("Invalid password for fisher with email " + request.email());
        }

        return fisher;
    }

    @Transactional
    public Fisher updateFisherPhoto(String email, MultipartFile photo) {
        Fisher fisher = fisherRepository.findByEmail(email);
        if (photo != null && !photo.isEmpty()) {
            try {
                fisher.setPhoto(photo.getBytes());
            } catch (Exception e) {
                throw new RuntimeException("Failed to read photo bytes", e);
            }
        }
        return fisherRepository.save(fisher);
    }

    @Transactional(readOnly = true)
    public List<Fisher> getTopFishers(int limit) {
        return fisherRepository.findAllByOrderByScoreDesc(PageRequest.of(0, limit));
    }

    @Transactional(readOnly = true)
    public List<Fisher> getAllFishers() {
        return fisherRepository.findAllByOrderByScoreDesc();
    }

}
