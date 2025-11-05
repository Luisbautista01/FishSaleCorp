package com.example.FishCorp.Model;

import jakarta.persistence.*;

import java.time.LocalDateTime;

@Entity
public class Pago {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne
    @JoinColumn(name = "pedido_id", nullable = false, unique = true)
    private Pedido pedido;

    @Column(nullable = false, unique = true)
    private String referenciaWompi; // ID único generado por Wompi

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private MetodoPago metodoPago; // CARD, PSE, NEQUI, DAVIPLATA

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private EstadoPago estado; // PENDIENTE, APROBADO, RECHAZADO

    @Column(nullable = false)
    private Double monto; // en COP

    private LocalDateTime fechaCreacion;
    private LocalDateTime fechaActualizacion;

    public Pago() {
        this.fechaCreacion = LocalDateTime.now();
        this.estado = EstadoPago.PENDIENTE;
    }

    public Pago(Pedido pedido, String referenciaWompi, MetodoPago metodoPago, Double monto) {
        this.pedido = pedido;
        this.referenciaWompi = referenciaWompi;
        this.metodoPago = metodoPago;
        this.monto = monto;
        this.fechaCreacion = LocalDateTime.now();
        this.estado = EstadoPago.PENDIENTE;
    }

    public enum EstadoPago {
        PENDIENTE,
        APROBADO,
        RECHAZADO
    }

    public enum MetodoPago {
        CARD,
        PSE,
        NEQUI,
        DAVIPLATA
    }

    @PrePersist
    public void prePersist() {
        if (fechaCreacion == null) {
            fechaCreacion = LocalDateTime.now();
        }
    }

    @PreUpdate
    public void preUpdate() {
        fechaActualizacion = LocalDateTime.now();
    }

    public Long getId() {
        return id;
    }

    public Pedido getPedido() {
        return pedido;
    }

    public void setPedido(Pedido pedido) {
        this.pedido = pedido;
    }

    public String getReferenciaWompi() {
        return referenciaWompi;
    }

    public void setReferenciaWompi(String referenciaWompi) {
        this.referenciaWompi = referenciaWompi;
    }

    public MetodoPago getMetodoPago() {
        return metodoPago;
    }

    public void setMetodoPago(MetodoPago metodoPago) {
        this.metodoPago = metodoPago;
    }

    public EstadoPago getEstado() {
        return estado;
    }

    public void setEstado(EstadoPago estado) {
        this.estado = estado;
    }

    public Double getMonto() {
        return monto;
    }

    public void setMonto(Double monto) {
        this.monto = monto;
    }

    public LocalDateTime getFechaCreacion() {
        return fechaCreacion;
    }

    public void setFechaCreacion(LocalDateTime fechaCreacion) {
        this.fechaCreacion = fechaCreacion;
    }

    public LocalDateTime getFechaActualizacion() {
        return fechaActualizacion;
    }

    public void setFechaActualizacion(LocalDateTime fechaActualizacion) {
        this.fechaActualizacion = fechaActualizacion;
    }
}
