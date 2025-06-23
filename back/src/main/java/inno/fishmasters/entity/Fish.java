package inno.fishmasters.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "fish")
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
public class Fish {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 255)
    private String name;

    @Lob
    @Column(nullable = true)
    private Byte[] photo;
}
