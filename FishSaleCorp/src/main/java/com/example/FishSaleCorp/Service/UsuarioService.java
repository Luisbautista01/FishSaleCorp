package com.example.FishSaleCorp.Service;

import com.example.FishSaleCorp.DTO.LoginRequest;
import com.example.FishSaleCorp.DTO.RegistroRequest;
import com.example.FishSaleCorp.DTO.UsuarioResponse;
import com.example.FishSaleCorp.Excepction.BadRequestException;
import com.example.FishSaleCorp.Excepction.ResourceNotFoundException;
import com.example.FishSaleCorp.Model.Usuario;
import com.example.FishSaleCorp.Repository.UsuarioRepository;
import com.example.FishSaleCorp.Security.JwtUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@Service
public class UsuarioService {

    private final UsuarioRepository usuarioRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtil jwtUtil;

    private static final Logger logger = LoggerFactory.getLogger(UsuarioService.class);

    @Autowired
    public UsuarioService(UsuarioRepository usuarioRepository,
                          PasswordEncoder passwordEncoder,
                          JwtUtil jwtUtil) {
        this.usuarioRepository = usuarioRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtUtil = jwtUtil;
    }

    public UsuarioResponse registrar(RegistroRequest request) {
        if (usuarioRepository.existsByEmail(request.getEmail())) {
            logger.warn("Intento de registro con un email ya existente: {}", request.getEmail());
            throw new BadRequestException("El email ya está registrado.");
        }

        if (request.getRol() == null || request.getRol().isBlank()) {
            logger.warn("Intento de registro sin rol especificado para el email: {}", request.getEmail());
            throw new BadRequestException("El rol es obligatorio.");
        }

        Usuario usuario = new Usuario();
        usuario.setNombre(request.getNombre());
        usuario.setEmail(request.getEmail());
        usuario.setPassword(passwordEncoder.encode(request.getPassword()));
        usuario.setRol(Usuario.Rol.valueOf(request.getRol().toUpperCase()));

        Usuario guardado = usuarioRepository.save(usuario);
        logger.info("Usuario registrado exitosamente: {} con rol {}", guardado.getEmail(), guardado.getRol());

        String token = jwtUtil.generarToken(guardado.getEmail(), guardado.getRol().name());
        logger.info("Token generado para {} con rol {}", guardado.getEmail(), guardado.getRol());

        return new UsuarioResponse(
                guardado.getId(),
                guardado.getNombre(),
                guardado.getEmail(),
                token,
                guardado.getRol().name()
        );
    }

    public UsuarioResponse login(LoginRequest request) {
        Usuario usuario = usuarioRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> {
                    logger.error("Intento de login con email no registrado: {}", request.getEmail());
                    return new ResourceNotFoundException("Usuario no encontrado con ese email: " + request.getEmail());
                });

        if (!passwordEncoder.matches(request.getPassword(), usuario.getPassword())) {
            logger.warn("Intento de login fallido: credenciales inválidas para {}", request.getEmail());
            throw new BadRequestException("Credenciales inválidas.");
        }

        logger.info("Inicio de sesión exitoso para {} con rol {}", usuario.getEmail(), usuario.getRol());
        String token = jwtUtil.generarToken(usuario.getEmail(), usuario.getRol().name());
        logger.info("Token JWT generado para {}", usuario.getEmail());

        return new UsuarioResponse(
                usuario.getId(),
                usuario.getNombre(),
                usuario.getEmail(),
                token,
                usuario.getRol().name()
        );
    }

    public List<UsuarioResponse> listarUsuarios() {
        logger.info("Listando todos los usuarios registrados en el sistema.");
        return usuarioRepository.findAll().stream()
                .map(u -> new UsuarioResponse(u.getId(), u.getNombre(), u.getEmail(), u.getRol().name()))
                .collect(Collectors.toList());
    }

    public void eliminarUsuario(Long id) {
        if (!usuarioRepository.existsById(id)) {
            logger.error("Intento de eliminar usuario inexistente con id {}", id);
            throw new ResourceNotFoundException("Usuario no encontrado con id " + id);
        }
        usuarioRepository.deleteById(id);
        logger.info("Usuario eliminado exitosamente con id {}", id);
    }

    public UsuarioResponse cambiarRolDeUsuario(Long id, String nuevoRol) {
        Usuario usuario = usuarioRepository.findById(id)
                .orElseThrow(() -> {
                    logger.error("No se encontró usuario con id {}", id);
                    return new ResourceNotFoundException("Usuario no encontrado con id " + id);
                });

        try {
            usuario.setRol(Usuario.Rol.valueOf(nuevoRol.toUpperCase()));
        } catch (IllegalArgumentException e) {
            logger.error("Rol inválido proporcionado: {}", nuevoRol);
            throw new BadRequestException("Rol inválido: " + nuevoRol);
        }

        Usuario actualizado = usuarioRepository.save(usuario);
        logger.info("Rol actualizado para {}. Nuevo rol: {}", actualizado.getEmail(), actualizado.getRol());

        return new UsuarioResponse(
                actualizado.getId(),
                actualizado.getNombre(),
                actualizado.getEmail(),
                actualizado.getRol().name()
        );
    }

    public List<UsuarioResponse> listarPorRol(String rol) {
        logger.info("Listando usuarios con rol {}", rol);
        return usuarioRepository.findByRol(Usuario.Rol.valueOf(rol.toUpperCase()))
                .stream()
                .map(u -> new UsuarioResponse(u.getId(), u.getNombre(), u.getEmail(), u.getRol().name()))
                .collect(Collectors.toList());
    }

    public void forgotPassword(String email) {
        usuarioRepository.findByEmail(email)
                .orElseThrow(() -> {
                    logger.error("Intento de recuperación de contraseña para email inexistente: {}", email);
                    return new ResourceNotFoundException("Usuario no encontrado con email: " + email);
                });

        logger.info("Simulación: se envió un correo de recuperación de contraseña a {}", email);
    }

    public void resetPassword(String email, String newPassword) {
        Usuario usuario = usuarioRepository.findByEmail(email)
                .orElseThrow(() -> {
                    logger.error("Intento de restablecer contraseña para email inexistente: {}", email);
                    return new ResourceNotFoundException("Usuario no encontrado con email: " + email);
                });

        usuario.setPassword(passwordEncoder.encode(newPassword));
        usuarioRepository.save(usuario);
        logger.info("Contraseña restablecida exitosamente para {}", email);
    }

    public UsuarioResponse actualizarUsuario(Long id, RegistroRequest request) {
        Usuario usuario = usuarioRepository.findById(id)
                .orElseThrow(() -> {
                    logger.error("Intento de actualización para usuario inexistente con id {}", id);
                    return new RuntimeException("Usuario no encontrado con id " + id);
                });

        if (request.getNombre() != null && !request.getNombre().isEmpty()) {
            usuario.setNombre(request.getNombre());
        }

        if (request.getEmail() != null && !request.getEmail().isEmpty()) {
            usuario.setEmail(request.getEmail());
        }

        if (request.getPassword() != null && !request.getPassword().isEmpty()) {
            usuario.setPassword(passwordEncoder.encode(request.getPassword()));
        }

        if (request.getRol() != null && !request.getRol().isEmpty()) {
            String rol = request.getRol().toUpperCase();
            if (!Arrays.stream(Usuario.Rol.values()).anyMatch(r -> r.name().equals(rol))) {
                logger.error("Intento de asignar rol inválido: {}", request.getRol());
                throw new RuntimeException("Rol inválido: " + request.getRol());
            }
            usuario.setRol(Usuario.Rol.valueOf(rol));
        }


        Usuario actualizado = usuarioRepository.save(usuario);
        logger.info("Usuario actualizado exitosamente: {}", actualizado.getEmail());

        return new UsuarioResponse(
                actualizado.getId(),
                actualizado.getNombre(),
                actualizado.getEmail(),
                actualizado.getRol().name()
        );
    }

    public UsuarioResponse obtenerPorId(Long id) {
        Usuario usuario = usuarioRepository.findById(id)
            .orElseThrow(() -> {
                logger.error("Usuario no encontrado con id {}", id);
                return new ResourceNotFoundException("Usuario no encontrado con id " + id);
            });

        logger.info("Usuario obtenido: {} con rol {}", usuario.getEmail(), usuario.getRol());
        return new UsuarioResponse(
            usuario.getId(),
            usuario.getNombre(),
            usuario.getEmail(),
            usuario.getRol().name()
        );
    }
}
