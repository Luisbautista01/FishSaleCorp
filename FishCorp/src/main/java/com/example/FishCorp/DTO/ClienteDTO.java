package com.example.FishCorp.DTO;

public class ClienteDTO {
    private Long id;
    private String nombre;

    public ClienteDTO(Long id, String nombre) {
        this.id = id;
        this.nombre = nombre;
    }

    public Long getId() {
        return id;
    }

    public String getNombre() {
        return nombre;
    }
}
