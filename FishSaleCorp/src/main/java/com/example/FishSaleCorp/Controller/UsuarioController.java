package com.example.FishSaleCorp.Controller;

import com.example.FishSaleCorp.DTO.UsuarioResponse;
import com.example.FishSaleCorp.Model.ReporteProblema;
import com.example.FishSaleCorp.Model.Usuario;
import com.example.FishSaleCorp.Repository.ReporteProblemaRepository;
import com.example.FishSaleCorp.Repository.UsuarioRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/usuarios")
@CrossOrigin(origins = "http://localhost:5000")
@PreAuthorize("hasAnyRole('CLIENTE', 'PESCADOR', 'ADMIN')")
public class UsuarioController {

    @Autowired
    private UsuarioRepository usuarioRepository;

    @Autowired
    private ReporteProblemaRepository reporteProblemaRepository;

    @GetMapping("/perfil")
    public UsuarioResponse obtenerPerfil(@AuthenticationPrincipal UserDetails userDetails) {
        Usuario usuario = usuarioRepository.findByEmail(userDetails.getUsername())
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado."));
        return new UsuarioResponse(
                usuario.getId(),
                usuario.getNombre(),
                usuario.getEmail(),
                usuario.getRol().name()
        );
    }

    @GetMapping("/mis-reportes")
    public List<ReporteProblema> obtenerMisReportes(@AuthenticationPrincipal UserDetails userDetails) {
        Usuario usuario = usuarioRepository.findByEmail(userDetails.getUsername())
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado."));
        return reporteProblemaRepository.findAll()
                .stream()
                .filter(r -> r.getUsuario().getId().equals(usuario.getId()))
                .toList();
    }

    @GetMapping("/test")
    public String testUserAccess(@AuthenticationPrincipal UserDetails userDetails) {
        return "Acceso permitido. Usuario autenticado: " + userDetails.getUsername();
    }
}
