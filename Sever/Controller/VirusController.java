package com.example.virus_information.controller;

import com.example.virus_information.dto.VirusDTO;
import com.example.virus_information.entity.Virus;
import com.example.virus_information.service.VirusService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.stream.Collectors;

@RestController
public class VirusController {
    private final VirusService virusService;

    @Autowired
    public VirusController(VirusService virusService) {
        this.virusService = virusService;
    }

    @GetMapping("/all")
    public List<VirusDTO> getAllVirusData() {
        List<Virus> viruses = virusService.getAllViruses();
        return viruses.stream()
                .map(virus -> new VirusDTO(virus.getDate(), virus.getRegion(), virus.getCases(), virus.getLatitude(), virus.getLongitude()))
                .collect(Collectors.toList());
    }

}
