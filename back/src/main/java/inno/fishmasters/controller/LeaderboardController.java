package inno.fishmasters.controller;

import inno.fishmasters.entity.Fisher;
import inno.fishmasters.service.FisherService;
import lombok.AllArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@AllArgsConstructor
@RestController
@RequestMapping("/api/leaderboard")
public class LeaderboardController {
    private final FisherService fisherService;

    @GetMapping("/top")
    public ResponseEntity<List<Fisher>> getTopFishers(@RequestParam(defaultValue = "10") int count) {
        return ResponseEntity.ok(fisherService.getTopFishers(count));
    }

    @GetMapping("/all")
    public ResponseEntity<List<Fisher>> getAllFishers() {
        return ResponseEntity.ok(fisherService.getAllFishers());
    }
}
