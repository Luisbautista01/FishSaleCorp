package com.example.FishCorp.DTO;

public class PescadorDTO {
    private Long id;
    private String nombre;

    public PescadorDTO(Long id, String nombre) {
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
