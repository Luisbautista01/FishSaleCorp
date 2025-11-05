package com.example.FishCorp.Model;

import java.time.LocalDateTime;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

import jakarta.persistence.*;

@Entity
public class Pedido {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "cliente_id")
    @JsonIgnoreProperties({"productos", "pedidos", "rol"})
    private Usuario cliente;

    @ManyToOne
    @JoinColumn(name = "producto_id")
    @JsonIgnoreProperties({"pescador"})
    private Producto producto;

    @ManyToOne
    @JoinColumn(name = "pescador_id")
    @JsonIgnoreProperties({"productos", "pedidos", "rol"})
    private Usuario pescador;

    private int cantidad;

    @Enumerated(EnumType.STRING)
    private EstadoPedido estado; // "PENDIENTE", "ENVIADO", "ENTREGADO"

    private LocalDateTime fechaCreacion;
    private String direccion;

    public Pedido(Long id, Usuario cliente, Producto producto, Usuario pescador, int cantidad,
                  EstadoPedido estado, String direccion) {
        this.id = id;
        this.cliente = cliente;
        this.producto = producto;
        this.pescador = pescador;
        this.cantidad = cantidad;
        this.estado = estado;
        this.direccion = direccion;
        this.fechaCreacion = LocalDateTime.now();
    }

    public Pedido() {
        this.fechaCreacion = LocalDateTime.now();
    }

    public enum EstadoPedido {
        PENDIENTE, ENVIADO, ENTREGADO, CANCELADO
    }

    @PrePersist
    public void prePersist() {
        if (fechaCreacion == null) {
            fechaCreacion = LocalDateTime.now();
        }
    }

    @Override
    public String toString() {
        return "Pedido{" +
                "id=" + id +
                ", cliente=" + (cliente != null ? cliente.getNombre() : "Sin cliente") +
                ", pescador=" + (pescador != null ? pescador.getNombre() : "Sin pescador") +
                ", producto=" + (producto != null ? producto.getNombre() : "Sin producto") +
                ", cantidad=" + cantidad +
                ", dirección=" + direccion +
                ", estado=" + estado +
                ", fechaCreacion=" + fechaCreacion +
                '}';
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Usuario getCliente() { return cliente; }
    public void setCliente(Usuario cliente) { this.cliente = cliente; }

    public Producto getProducto() { return producto; }
    public void setProducto(Producto producto) { this.producto = producto; }

    public Usuario getPescador() { return pescador; }
    public void setPescador(Usuario pescador) { this.pescador = pescador; }

    public int getCantidad() { return cantidad; }
    public void setCantidad(int cantidad) { this.cantidad = cantidad; }

    public EstadoPedido getEstado() { return estado; }
    public void setEstado(EstadoPedido estado) {this.estado = estado; }

    public LocalDateTime getFechaCreacion() { return fechaCreacion; }
    public void setFechaCreacion(LocalDateTime fechaCreacion) { this.fechaCreacion = fechaCreacion; }

    public String getDireccion() {
        return direccion;
    }

    public void setDireccion(String direccion) {
        this.direccion = direccion;
    }
}
