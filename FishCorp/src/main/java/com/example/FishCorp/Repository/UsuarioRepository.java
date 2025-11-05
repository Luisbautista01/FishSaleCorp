package com.example.FishCorp.Repository;

import com.example.FishCorp.Model.Usuario;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface UsuarioRepository extends JpaRepository<Usuario, Long> {
    Optional<Usuario> findByEmail(String email);
    boolean existsByEmail(String email);
    List<Usuario> findByRol(Usuario.Rol rol);
    Optional<Usuario> findByNombre(String nombre);
}
