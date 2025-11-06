package com.example.FishSaleCorp.DTO;

import java.util.List;

public class ResumenCompletoPescador {
    private String pescador;
    private Double totalPagado;
    private List<ResumenPagoPescadorProducto> detallePorProducto;

    public ResumenCompletoPescador(String pescador, Double totalPagado, List<ResumenPagoPescadorProducto> detallePorProducto) {
        this.pescador = pescador;
        this.totalPagado = totalPagado;
        this.detallePorProducto = detallePorProducto;
    }

    public String getPescador() {
        return pescador;
    }

    public void setPescador(String pescador) {
        this.pescador = pescador;
    }

    public Double getTotalPagado() {
        return totalPagado;
    }

    public void setTotalPagado(Double totalPagado) {
        this.totalPagado = totalPagado;
    }

    public List<ResumenPagoPescadorProducto> getDetallePorProducto() {
        return detallePorProducto;
    }

    public void setDetallePorProducto(List<ResumenPagoPescadorProducto> detallePorProducto) {
        this.detallePorProducto = detallePorProducto;
    }
}
