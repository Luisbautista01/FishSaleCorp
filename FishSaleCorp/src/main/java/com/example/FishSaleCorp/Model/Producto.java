package com.example.FishSaleCorp.Model;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

import jakarta.persistence.*;

@Entity
public class Producto {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String nombre;
    private Double precio;
    private Integer cantidad;

    @ManyToOne
    @JoinColumn(name = "pescador_id", nullable = false)
    @JsonIgnoreProperties({"productos", "pedidos", "password", "email"})
    private Usuario pescador;

    private String categoria;
    private String imagen;

    private Double descuento;

    public Producto() {
    }

    public Producto(Long id, String nombre, Double precio, Integer cantidad, Usuario pescador, String categoria, String imagen, Double descuento) {
        this.id = id;
        this.nombre = nombre;
        this.precio = precio;
        this.cantidad = cantidad;
        this.pescador = pescador;
        this.categoria = categoria;
        this.imagen = imagen;
        this.descuento = descuento;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

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

    public Usuario getPescador() {
        return pescador;
    }

    public void setPescador(Usuario pescador) {
        this.pescador = pescador;
    }

    public String getCategoria(){
        return categoria;
    }

    public void setCategoria( String categoria){
        this.categoria = categoria;
    }

    public String getImagen(){
        return imagen;
    }

    public void setImagen(String imagen){
        this.imagen = imagen;
    }

    public Double getDescuento() {
        return descuento;
    }

    public void setDescuento(Double descuento) {
        this.descuento = descuento;
    }

}
