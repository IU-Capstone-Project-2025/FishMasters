package inno.fishmasters.entity;

import com.fasterxml.jackson.annotation.JsonManagedReference;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;
import java.util.List;

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
    private String userEmail;

    @Column(nullable = false)
    private LocalDateTime startTime;

    @Column(nullable = true)
    private LocalDateTime endTime;

    @OneToMany(mappedBy = "fishing", cascade = CascadeType.ALL, orphanRemoval = true)
    @JsonManagedReference
    private List<CaughtFish> caughtFish;

    @ManyToOne
    @JoinColumn(name = "water_id", nullable = false)
    private Water water;
}