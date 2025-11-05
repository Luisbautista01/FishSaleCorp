package com.example.FishCorp.DTO;

public class UsuarioResponse {
    private Long id;
    private String nombre;
    private String email;
    private String token;
    private String rol;

    public UsuarioResponse(Long id, String nombre, String email, String rol) {
        this.id = id;
        this.nombre = nombre;
        this.email = email;
        this.rol = rol;
    }

    public UsuarioResponse(Long id, String nombre, String email, String token, String rol) {
        this.id = id;
        this.nombre = nombre;
        this.email = email;
        this.token = token;
        this.rol = rol;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getToken() {
        return token;
    }

    public void setToken(String token) {
        this.token = token;
    }

    public String getRol() {
        return rol;
    }

    public void setRol(String rol) {
        this.rol = rol;
    }
}
