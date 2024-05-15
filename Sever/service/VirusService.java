package com.example.virus_information.service;

import com.example.virus_information.entity.Virus;
import com.example.virus_information.repository.VirusRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class VirusService {
    private final VirusRepository virusRepository;

    @Autowired
    public VirusService(VirusRepository virusRepository) {
        this.virusRepository = virusRepository;
    }

    
    public List<Virus> getAllViruses() {
        return virusRepository.findAll();
    }
}
