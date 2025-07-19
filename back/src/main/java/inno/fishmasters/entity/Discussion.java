package inno.fishmasters.entity;

import com.fasterxml.jackson.annotation.JsonBackReference;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "discussion")
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
public final class Discussion {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne
    @JoinColumn(name = "water_id", nullable = false, unique = true)
    @JsonBackReference
    private Water water;

}
