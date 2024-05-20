package com.example.virus_information.dto;

import java.time.LocalDateTime;
import java.util.List;

public class RouteDTO {
    private LocalDateTime timestamp;
    private double latitude;
    private double longitude;
    private String locations;
    private int identifier;


    public RouteDTO(LocalDateTime timestamp, double latitude, double longitude, String locations, int identifier) {
        this.timestamp = timestamp;
        this.latitude = latitude;
        this.longitude = longitude;
        this.locations = locations;
        this.identifier = identifier;
    }
}
