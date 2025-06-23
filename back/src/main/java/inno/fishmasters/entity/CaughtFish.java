package inno.fishmasters.entity;

import com.fasterxml.jackson.annotation.JsonBackReference;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "caught_fish")
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
public class CaughtFish {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String name;

    @ManyToOne
    @JoinColumn(name = "fishing_id", nullable = false)
    @JsonBackReference
    private Fishing fishing;

    @ManyToOne
    @JoinColumn(name = "fish_id", nullable = false)
    private Fish fish;
}