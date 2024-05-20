package com.example.virus_information.repository;

import com.example.virus_information.entity.Route;
import com.example.virus_information.entity.Virus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface RouteRepository extends JpaRepository<Route, Long> {
    List<Route> findByIdentifier(Long identifier);
}
