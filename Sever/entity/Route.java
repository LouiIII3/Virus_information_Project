package com.example.virus_information.entity;

import jakarta.persistence.*;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;

@Entity
@Data
public class Route {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private int identifier; // 확진자 ID
    private LocalDateTime timestamp; // 시간 정보

    // 위도와 경도를 포함합니다.
    private double latitude;
    private double longitude;

    private String locations;
}
