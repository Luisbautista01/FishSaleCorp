package com.example.FishSaleCorp.DTO;

public class ProductoRequest {
    private String nombre;
    private Double precio;
    private Integer cantidad;
    private Long pescadorId;
    private String categoria;
    private String imagen;
    private Double descuento;

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public Double getPrecio() {
        return precio;
    }

    public void setPrecio(Double precio) {
        this.precio = precio;
    }

    public Integer getCantidad() {
        return cantidad;
    }

    public void setCantidad(Integer cantidad) {
        this.cantidad = cantidad;
    }

    public Long getPescadorId() {
        return pescadorId;
    }

    public void setPescadorId(Long pescadorId) {
        this.pescadorId = pescadorId;
    }

    public String getCategoria() { 
        return categoria; 
    }

    public void setCategoria(String categoria) { 
        this.categoria = categoria; 
    }

    public String getImagen() { 
        return imagen; 
    }

    public void setImagen(String imagen) { 
        this.imagen = imagen; 
    }

    public Double getDescuento() {
        return descuento;
    }

    public void setDescuento(Double descuento) {
        this.descuento = descuento;
    }
}
