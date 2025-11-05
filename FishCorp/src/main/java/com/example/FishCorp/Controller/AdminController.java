package com.example.FishCorp.Controller;

import com.example.FishCorp.DTO.CambioRolRequest;
import com.example.FishCorp.DTO.RegistroRequest;
import com.example.FishCorp.DTO.UsuarioResponse;
import com.example.FishCorp.Service.UsuarioService;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/admin")
@CrossOrigin(origins = "http://localhost:5000")
@PreAuthorize("hasRole('ADMIN')")
public class AdminController {

    @Autowired
    private UsuarioService usuarioService;

    @GetMapping("/usuarios")
    @PreAuthorize("hasRole('ADMIN')")
    public List<UsuarioResponse> listarUsuarios() {
        return usuarioService.listarUsuarios();
    }

    @GetMapping("/usuarios/pescadores")
    @PreAuthorize("hasRole('ADMIN')")
    public List<UsuarioResponse> listarPescadores() {
        return usuarioService.listarPorRol("PESCADOR");
    }

    @GetMapping("/usuarios/clientes")
    @PreAuthorize("hasRole('ADMIN')")
    public List<UsuarioResponse> listarClientes() {
        return usuarioService.listarPorRol("CLIENTE");
    }

    @DeleteMapping("/usuarios/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public void eliminarUsuario(@PathVariable("id") Long id) {
        usuarioService.eliminarUsuario(id);
    }

    @PutMapping("/usuarios/cambiar_rol/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public UsuarioResponse cambiarRolDeUsuario(@PathVariable("id") Long id, @RequestBody CambioRolRequest request) {
        return usuarioService.cambiarRolDeUsuario(id, request.getNuevoRol());
    }

    @PostMapping("/usuarios")
    @PreAuthorize("hasRole('ADMIN')")
    public UsuarioResponse crearUsuario(@RequestBody RegistroRequest request) {
        return usuarioService.registrar(request);
    }

    @PutMapping("/usuarios/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public UsuarioResponse actualizarUsuario(
            @PathVariable("id") Long id, 
            @RequestBody RegistroRequest request) {
        return usuarioService.actualizarUsuario(id, request);
    }


    @GetMapping("/usuarios/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public UsuarioResponse obtenerUsuario(@PathVariable Long id) {
        return usuarioService.obtenerPorId(id);
    }

    @GetMapping("/test")
    @PreAuthorize("hasRole('ADMIN')")
    public String testAdminAccess() {
        return "Acceso permitido: eres ADMIN y el token es válido.";
    }
}

