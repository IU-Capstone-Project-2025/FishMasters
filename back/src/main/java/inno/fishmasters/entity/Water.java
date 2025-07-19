package inno.fishmasters.entity;

import com.fasterxml.jackson.annotation.JsonManagedReference;
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

    public Water(Double id, Double x, Double y) {
        this.id = id;
        this.x = x;
        this.y = y;
    }

    @Id
    private Double id;

    @Column(nullable = false)
    private Double x;

    @Column(nullable = false)
    private Double y;

    @OneToOne(mappedBy = "water", cascade = CascadeType.ALL, orphanRemoval = true)
    @JsonManagedReference
    private Discussion discussion;
}