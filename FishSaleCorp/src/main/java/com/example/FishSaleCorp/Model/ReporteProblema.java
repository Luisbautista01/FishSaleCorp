package com.example.FishSaleCorp.Model;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "reporte_problema")
public class ReporteProblema {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    @ManyToOne(fetch = FetchType.EAGER) 
    @JoinColumn(name = "usuario_id", nullable = false)
    private Usuario usuario;

    private String descripcion;
    private String imagenUrl; 
    private boolean resolver = false;

    private LocalDateTime fechaSolicitud = LocalDateTime.now();
    private LocalDateTime fechaAtencion;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Usuario getUsuario() {
        return usuario;
    }

    public void setUsuario(Usuario usuario) {
        this.usuario = usuario;
    }

    public String getDescripcion() {
        return descripcion;
    }

    public void setDescripcion(String descripcion) {
        this.descripcion = descripcion;
    }

    public String getImagenUrl() {
        return imagenUrl;
    }

    public void setImagenUrl(String imagenUrl) {
        this.imagenUrl = imagenUrl;
    }

    public boolean isResolver() {
        return resolver;
    }

    public void setResolver(boolean resolver) {
        this.resolver = resolver;
    }

    public LocalDateTime getFechaSolicitud() {
        return fechaSolicitud;
    }

    public void setFechaSolicitud(LocalDateTime fechaSolicitud) {
        this.fechaSolicitud = fechaSolicitud;
    }

    public LocalDateTime getFechaAtencion() {
        return fechaAtencion;
    }

    public void setFechaAtencion(LocalDateTime fechaAtencion) {
        this.fechaAtencion = fechaAtencion;
    }
}
