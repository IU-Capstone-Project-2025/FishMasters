package inno.fishmasters.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "fishers")
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
public class Fisher {

    @Id
    @Column(nullable = false, unique = true, length = 255)
    private String email;

    @Column(nullable = false, length = 255)
    private String name;

    @Column(nullable = false, length = 255)
    private String surname;

    @Column(nullable = false, length = 255)
    private String password;

    @Column(nullable = false)
    private Integer score;

    @Lob
    @Column(nullable = true)
    private Byte[] photo;

}
