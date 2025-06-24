package inno.fishmasters;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import io.swagger.v3.oas.annotations.OpenAPIDefinition;
import io.swagger.v3.oas.annotations.servers.Server;

@OpenAPIDefinition(
        servers = {
                @Server(url = "https://capstone.aquaf1na.fun:8080", description = "Production server"),
                @Server(url = "http://localhost:8080", description = "Local server")
        }
)
@SpringBootApplication
public class FishMastersApplication {

    public static void main(String[] args) {
        SpringApplication.run(FishMastersApplication.class, args);
    }

}
