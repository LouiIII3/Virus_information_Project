package com.example.virus_information.dto;

import lombok.Getter;
import lombok.Setter;

import java.time.LocalDate;

@Getter
@Setter
public class VirusDTO {
    private LocalDate date;
    private String region;
    private int cases;
    //위도
    private double latitude;
    //경도
    private double longitude;
    public VirusDTO(LocalDate date, String region, int cases,double latitude,double longitude) {
        this.date = date;
        this.region = region;
        this.cases = cases;
        this.latitude = latitude;
        this.longitude = longitude;
    }
}
