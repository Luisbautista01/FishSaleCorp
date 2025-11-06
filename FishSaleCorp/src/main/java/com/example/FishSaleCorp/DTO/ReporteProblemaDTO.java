package com.example.FishSaleCorp.DTO;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import com.example.FishSaleCorp.Model.ReporteProblema;

public class ReporteProblemaDTO {
    private Long id;
    private String descripcion;
    private String imagenUrl;
    private Long usuarioId;
    private String nombreUsuario;
    private String fechaSolicitud;
    private boolean resolver;

    public ReporteProblemaDTO(Long id, String descripcion, String imagenUrl, Long usuarioId,
                              String nombreUsuario, LocalDateTime fechaSolicitud, boolean resolver) {
        this.id = id != null ? id : 0L;
        this.descripcion = descripcion != null ? descripcion : "Sin descripción";
        this.imagenUrl = imagenUrl;
        this.usuarioId = usuarioId != null ? usuarioId : 0L;
        this.nombreUsuario = nombreUsuario != null ? nombreUsuario : "Usuario desconocido";
        this.fechaSolicitud = fechaSolicitud != null
                ? fechaSolicitud.format(DateTimeFormatter.ofPattern("yyyy-MM-dd"))
                : "—";
        this.resolver = resolver;
    }

    public ReporteProblemaDTO(ReporteProblema rp) {
        this(
            rp.getId(),
            rp.getDescripcion(),
            rp.getImagenUrl(),
            rp.getUsuario() != null ? rp.getUsuario().getId() : 0L,
            rp.getUsuario() != null ? rp.getUsuario().getNombre() : "Usuario desconocido",
            rp.getFechaSolicitud(),
            rp.isResolver()
        );
    }

    public Long getId() { return id; }
    public String getDescripcion() { return descripcion; }
    public String getImagenUrl() { return imagenUrl; }
    public Long getUsuarioId() { return usuarioId; }
    public String getNombreUsuario() { return nombreUsuario; }
    public String getFechaSolicitud() { return fechaSolicitud; }
    public boolean isResolver() { return resolver; }
}
