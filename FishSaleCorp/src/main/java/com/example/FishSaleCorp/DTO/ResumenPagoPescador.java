package com.example.FishSaleCorp.DTO;

public class ResumenPagoPescador {
    private String pescador;
    private Double totalPagado;

    public ResumenPagoPescador(String pescador, Double totalPagado) {
        this.pescador = pescador;
        this.totalPagado = totalPagado;
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
}
