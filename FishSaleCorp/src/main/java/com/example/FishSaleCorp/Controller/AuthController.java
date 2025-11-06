package com.example.FishSaleCorp.Controller;

import com.example.FishSaleCorp.DTO.LoginRequest;
import com.example.FishSaleCorp.DTO.RegistroRequest;
import com.example.FishSaleCorp.DTO.UsuarioResponse;
import com.example.FishSaleCorp.Service.UsuarioService;
import jakarta.validation.Valid;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/auth")
@CrossOrigin(origins = "http://localhost:5000")
public class AuthController {

    private static final Logger logger = LoggerFactory.getLogger(AuthController.class);

    @Autowired
    private UsuarioService usuarioService;

    @PostMapping("/registro")
    public ResponseEntity<UsuarioResponse> registrar(@Valid @RequestBody RegistroRequest request) {
        logger.info("Solicitud de registro recibida para el email: {}", request.getEmail());
        try {
            UsuarioResponse response = usuarioService.registrar(request);
            logger.info("Usuario registrado exitosamente: {}", response.getEmail());
            return ResponseEntity.status(201).body(response);
        } catch (Exception e) {
            logger.error("Error al registrar usuario {}: {}", request.getEmail(), e.getMessage());
            throw e;
        }
    }

    @PostMapping("/login")
    public ResponseEntity<UsuarioResponse> login(@Valid @RequestBody LoginRequest request) {
        logger.info("Intento de inicio de sesión para el email: {}", request.getEmail());
        try {
            UsuarioResponse response = usuarioService.login(request);
            logger.info("Inicio de sesión exitoso para: {}", response.getEmail());
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            logger.warn("Fallo en inicio de sesión para {}: {}", request.getEmail(), e.getMessage());
            throw e;
        }
    }

    @PostMapping("/forgot-password")
    public ResponseEntity<String> forgotPassword(@RequestBody Map<String, String> request) {
        String email = request.get("email");
        logger.info("Solicitud de recuperación de contraseña recibida para: {}", email);
        try {
            usuarioService.forgotPassword(email);
            logger.info("Correo de recuperación (simulado) enviado a: {}", email);
            return ResponseEntity.ok("Se envió un correo de recuperación (simulado).");
        } catch (Exception e) {
            logger.error("Error en solicitud de recuperación de contraseña para {}: {}", email, e.getMessage());
            throw e;
        }
    }

    @PostMapping("/reset-password")
    public ResponseEntity<String> resetPassword(@RequestBody Map<String, String> request) {
        String email = request.get("email");
        String newPassword = request.get("newPassword");
        logger.info("Solicitud de restablecimiento de contraseña para: {}", email);
        try {
            usuarioService.resetPassword(email, newPassword);
            logger.info("Contraseña actualizada exitosamente para: {}", email);
            return ResponseEntity.ok("Contraseña actualizada con éxito.");
        } catch (Exception e) {
            logger.error("Error al restablecer contraseña para {}: {}", email, e.getMessage());
            throw e;
        }
    }
}
