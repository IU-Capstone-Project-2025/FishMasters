package inno.fishmasters.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.List;

@Entity
@Table(name = "water")
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
public class Water {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private double x;

    @Column(nullable = false)
    private double y;

    @OneToMany(mappedBy = "water", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<Fishing> fishings;
}