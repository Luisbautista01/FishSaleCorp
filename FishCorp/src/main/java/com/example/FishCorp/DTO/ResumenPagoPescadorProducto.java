package com.example.FishCorp.DTO;

public class ResumenPagoPescadorProducto {
    private String pescador;
    private String producto;
    private String cliente; // nuevo campo
    private Double totalPagado;

    public ResumenPagoPescadorProducto(String pescador, String producto, String cliente, Double totalPagado) {
        this.pescador = pescador;
        this.producto = producto;
        this.cliente = cliente;
        this.totalPagado = totalPagado;
    }

    public String getPescador() {
        return pescador;
    }

    public void setPescador(String pescador) {
        this.pescador = pescador;
    }

    public String getProducto() {
        return producto;
    }

    public void setProducto(String producto) {
        this.producto = producto;
    }

    public String getCliente() {
        return cliente;
    }

    public void setCliente(String cliente) {
        this.cliente = cliente;
    }

    public Double getTotalPagado() {
        return totalPagado;
    }

    public void setTotalPagado(Double totalPagado) {
        this.totalPagado = totalPagado;
    }
}
