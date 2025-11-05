package com.example.FishCorp.DTO;

import java.time.LocalDateTime;

import com.example.FishCorp.Model.Pedido;
import com.example.FishCorp.Model.Producto;

public class PedidoResponse {
    private Long id;
    private ClienteDTO cliente;
    private PescadorDTO pescador;
    private Producto producto;
    private int cantidad;
    private String estado;
    private LocalDateTime fechaCreacion;
    private String direccion;

    public PedidoResponse(Long id, ClienteDTO cliente, PescadorDTO pescador, Producto producto,
                        int cantidad, String estado, LocalDateTime fechaCreacion, String direccion) {
        this.id = id;
        this.cliente = cliente;
        this.pescador = pescador;
        this.producto = producto;
        this.cantidad = cantidad;
        this.estado = estado;
        this.fechaCreacion = fechaCreacion;
        this.direccion = direccion;
    }

    public static PedidoResponse fromEntity(Pedido pedido) {
        return new PedidoResponse(
                pedido.getId(),
                new ClienteDTO(pedido.getCliente().getId(), pedido.getCliente().getNombre()),
                pedido.getPescador() != null
                    ? new PescadorDTO(pedido.getPescador().getId(), pedido.getPescador().getNombre())
                    : null,
                pedido.getProducto(),
                pedido.getCantidad(),
                pedido.getEstado().name(),
                pedido.getFechaCreacion(),
                pedido.getDireccion()
        );
    }

    public Long getId() {
        return id;
    }

    public ClienteDTO getCliente() {
        return cliente;
    }

    public PescadorDTO getPescador() {
        return pescador;
    }

    public Producto getProducto() {
        return producto;
    }

    public int getCantidad() {
        return cantidad;
    }

    public String getEstado() {
        return estado;
    }

    public LocalDateTime getFechaCreacion() {
        return fechaCreacion;
    }

    public String getDireccion() {
        return direccion;
    }

    public void setDireccion(String direccion) {
        this.direccion = direccion;
    }
}
