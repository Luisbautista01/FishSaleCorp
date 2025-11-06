package com.example.FishSaleCorp.DTO;

import java.math.BigDecimal;

public class TotalPorPescadorDTO {
    private Long pescadorId;
    private String pescador;
    private BigDecimal total;
    private Long cantidadVentas;

    public TotalPorPescadorDTO(Long pescadorId, String pescador, BigDecimal total, Long cantidadVentas) {
        this.pescadorId = pescadorId;
        this.pescador = pescador;
        this.total = total;
        this.cantidadVentas = cantidadVentas;
    }

    public Long getPescadorId() { return pescadorId; }
    public String getPescador() { return pescador; }
    public BigDecimal getTotal() { return total; }
    public Long getCantidadVentas() { return cantidadVentas; }
}

