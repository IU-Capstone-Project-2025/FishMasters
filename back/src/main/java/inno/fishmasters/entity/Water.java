package inno.fishmasters.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "waters")
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
public class Water {

    @Id
    private Double id;

    @Column(nullable = false)
    private Double x;

    @Column(nullable = false)
    private Double y;
}