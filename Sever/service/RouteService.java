package com.example.virus_information.service;

import com.example.virus_information.dto.RouteDTO;
import com.example.virus_information.entity.Route;
import com.example.virus_information.repository.RouteRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class RouteService {
    private final RouteRepository routeRepository;

    @Autowired
    public RouteService(RouteRepository routeRepository) {
        this.routeRepository = routeRepository;
    }

    public List<Route> findByIdentifier(Long identifier) {
        return routeRepository.findByIdentifier(identifier);
    }
}
