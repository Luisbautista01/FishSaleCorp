package com.example.FishCorp.DTO;

import com.example.FishCorp.Model.Pago;
import java.time.LocalDateTime;

public class PagoResponse {
    private Long id;
    private Long pedidoId;
    private String referenciaWompi;
    private String metodoPago;
    private String estado;
    private Double monto;
    private LocalDateTime fechaCreacion;
    private String cliente;
    private String pescador;
    private String productoNombre;
    private Long pescadorId;
    private Integer cantidad; 

    public PagoResponse(Long id, Long pedidoId, String referenciaWompi,
                        String metodoPago, String estado, Double monto,
                        LocalDateTime fechaCreacion, String cliente,
                        String pescador, String productoNombre, Long pescadorId,
                        Integer cantidad) { 
        this.id = id;
        this.pedidoId = pedidoId;
        this.referenciaWompi = referenciaWompi;
        this.metodoPago = metodoPago;
        this.estado = estado;
        this.monto = monto;
        this.fechaCreacion = fechaCreacion;
        this.cliente = cliente;
        this.pescador = pescador;
        this.productoNombre = productoNombre;
        this.pescadorId = pescadorId;
        this.cantidad = cantidad;
    }

    public static PagoResponse fromEntity(Pago pago) {
        if (pago == null) {
            return new PagoResponse(
                    null,
                    null,
                    "Sin referencia",
                    "Desconocido",
                    "DESCONOCIDO",
                    0.0,
                    null,
                    "Sin cliente",
                    "Sin pescador",
                    "Producto no disponible",
                    null,
                    0
            );
        }

        try {
            Long pedidoId = null;
            String cliente = "Sin cliente";
            String pescador = "Sin pescador";
            String productoNombre = "Producto no disponible";
            Long pescadorId = null;
            Integer cantidad = 0;

            if (pago.getPedido() != null) {
                pedidoId = pago.getPedido().getId();
                cantidad = pago.getPedido().getCantidad();

                if (pago.getPedido().getCliente() != null) {
                    cliente = pago.getPedido().getCliente().getNombre();
                }

                if (pago.getPedido().getProducto() != null) {
                    productoNombre = pago.getPedido().getProducto().getNombre();

                    if (pago.getPedido().getProducto().getPescador() != null) {
                        pescador = pago.getPedido().getProducto().getPescador().getNombre();
                        pescadorId = pago.getPedido().getProducto().getPescador().getId();
                    }
                }
            }

            return new PagoResponse(
                    pago.getId(),
                    pedidoId,
                    pago.getReferenciaWompi() != null ? pago.getReferenciaWompi() : "Sin referencia",
                    pago.getMetodoPago() != null ? pago.getMetodoPago().name() : "Desconocido",
                    pago.getEstado() != null ? pago.getEstado().name() : "Desconocido",
                    pago.getMonto() != null ? pago.getMonto() : 0.0,
                    pago.getFechaCreacion(),
                    cliente,
                    pescador,
                    productoNombre,
                    pescadorId,
                    cantidad
            );

        } catch (Exception ex) {
            ex.printStackTrace();
            return new PagoResponse(
                    pago.getId(),
                    null,
                    "Sin referencia",
                    "Desconocido",
                    "DESCONOCIDO",
                    0.0,
                    pago.getFechaCreacion(),
                    "Sin cliente",
                    "Sin pescador",
                    "Producto no disponible",
                    null,
                    0
            );
        }
    }

    // Getters y Setters
    public Long getId() { return id; }
    public Long getPedidoId() { return pedidoId; }
    public String getReferenciaWompi() { return referenciaWompi; }
    public String getMetodoPago() { return metodoPago; }
    public String getEstado() { return estado; }
    public Double getMonto() { return monto; }
    public LocalDateTime getFechaCreacion() { return fechaCreacion; }
    public String getCliente() { return cliente; }
    public String getPescador() { return pescador; }
    public String getProductoNombre() { return productoNombre; }
    public Long getPescadorId() { return pescadorId; }

    public void setProductoNombre(String productoNombre) {
        this.productoNombre = productoNombre;
    }

    public Integer getCantidad() {
        return cantidad;
    }
}
