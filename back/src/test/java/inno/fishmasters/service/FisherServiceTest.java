package inno.fishmasters.service;

import inno.fishmasters.dto.request.auth.CreateFisherRequest;
import inno.fishmasters.entity.Fisher;
import inno.fishmasters.exception.FisherIsExistException;
import inno.fishmasters.exception.FishingIsNotExistException;
import inno.fishmasters.repository.FisherRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.Mockito.when;

public class FisherServiceTest {

    @Mock
    private FisherRepository fisherRepository;

    @InjectMocks
    private FisherService fisherService;

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
    }

    @Test
    void registerFisher_successfully() {
        String email = "ex@example.com";
        String name = "kostyan";
        String surname = "surname";
        String password = "123456789";
        CreateFisherRequest request = new CreateFisherRequest(
                email,
                name,
                surname,
                password,
                null // photo is optional and can be null for now
        );

        Fisher fisher = new Fisher(
                email,
                name,
                surname,
                password,
                0, // initial score starts at 0
                null // without photo for now
        );

        when(fisherRepository.existsById(email)).thenReturn(false);
        when(fisherRepository.save(fisher)).thenReturn(fisher);

        assertEquals(fisherService.register(request), null);

    }

    @Test
    void registerFisher_throwsError() {
        String email = "ex@example.com";
        String name = "kostyan";
        String surname = "surname";
        String password = "123456789";
        CreateFisherRequest request = new CreateFisherRequest(
                email,
                name,
                surname,
                password,
                null // photo is optional and can be null for now
        );

        Fisher fisher = new Fisher(
                email,
                name,
                surname,
                password,
                0, // initial score starts at 0
                null // without photo for now
        );

        when(fisherRepository.existsById(email)).thenReturn(true);
        when(fisherRepository.save(fisher)).thenReturn(fisher);

        assertThrows(FisherIsExistException.class, () -> fisherService.register(request));

    }

}
