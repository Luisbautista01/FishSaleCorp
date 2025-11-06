package com.example.FishSaleCorp.Service;

import com.example.FishSaleCorp.DTO.ReporteProblemaDTO;
import com.example.FishSaleCorp.DTO.ReporteProblemaRequest;
import com.example.FishSaleCorp.Excepction.ResourceNotFoundException;
import com.example.FishSaleCorp.Model.ReporteProblema;
import com.example.FishSaleCorp.Model.Usuario;
import com.example.FishSaleCorp.Repository.ReporteProblemaRepository;
import com.example.FishSaleCorp.Repository.UsuarioRepository;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class ReporteProblemaService {

    @Autowired
    private ReporteProblemaRepository reporteProblemaRepository;

    @Autowired
    private UsuarioRepository usuarioRepository;

    public ReporteProblema crearReporteProblema(ReporteProblemaRequest request) {
        Usuario usuario = usuarioRepository.findById(request.getUsuarioId())
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Usuario no encontrado con ID " + request.getUsuarioId()));

        ReporteProblema report = new ReporteProblema();
        report.setUsuario(usuario);
        report.setDescripcion(request.getDescripcion());
        report.setImagenUrl(request.getImagenUrl());

        return reporteProblemaRepository.save(report);
    }

    @Transactional(readOnly = true)
    public List<ReporteProblemaDTO> obtenerProblemasPendientes() {
        return reporteProblemaRepository.findByResolverFalse()
                .stream()
                .map(ReporteProblemaDTO::new)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<ReporteProblemaDTO> obtenerReportesPorUsuario(Long usuarioId) {
        try {
            return reporteProblemaRepository.findReportesPorUsuario(usuarioId);
        } catch (Exception e) {
            System.err.println("Error al obtener reportes del usuario " + usuarioId + ": " + e.getMessage());
            return List.of();
        }
    }

    public ReporteProblema marcarComoResuelto(Long id) {
        ReporteProblema report = reporteProblemaRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Reporte no encontrado con ID " + id));
        report.setResolver(true);
        report.setFechaAtencion(LocalDateTime.now());
        return reporteProblemaRepository.save(report);
    }
}
