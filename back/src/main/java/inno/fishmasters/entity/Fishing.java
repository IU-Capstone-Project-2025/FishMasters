package inno.fishmasters.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Set;

@Entity
@Table(name = "fishing")
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
public class Fishing {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private LocalDateTime startTime;

    @Column(nullable = false)
    private LocalDateTime endTime;

    @OneToMany(mappedBy = "fishing", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<CaughtFish> caughtFish;
}