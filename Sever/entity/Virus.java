package com.example.virus_information.entity;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import lombok.Data;

import java.time.LocalDate;

@Entity
@Data
public class Virus {
    @Id
    private Long id;

    private LocalDate Date;
    private String region;
    //확진자 번호(추후 변경 예정)
    private int cases;
    //위도
    private double latitude;
    //경도
    private double longitude;
}
