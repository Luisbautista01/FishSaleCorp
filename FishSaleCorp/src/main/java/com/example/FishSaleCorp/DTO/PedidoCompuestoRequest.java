package com.example.FishSaleCorp.DTO;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import java.util.List;

public class PedidoCompuestoRequest {

    @NotNull(message = "La lista de productos es obligatoria")
    private List<ProductoCantidad> productos;
    @NotNull(message = "La dirección es obligatoria")
    private String direccion;

    public List<ProductoCantidad> getProductos() {
        return productos;
    }

    public void setProductos(List<ProductoCantidad> productos) {
        this.productos = productos;
    }

    public String getDireccion() { return direccion; }
    public void setDireccion(String direccion) { this.direccion = direccion; }

    public static class ProductoCantidad {
        @NotNull(message = "El productoId es obligatorio")
        private Long productoId;

        @NotNull(message = "La cantidad es obligatoria")
        @Min(value = 1, message = "La cantidad debe ser al menos 1")
        private Integer cantidad;

        public Long getProductoId() { return productoId; }
        public void setProductoId(Long productoId) { this.productoId = productoId; }

        public Integer getCantidad() { return cantidad; }
        public void setCantidad(Integer cantidad) { this.cantidad = cantidad; }
    }
}
