package com.example.FishCorp.DTO;

import com.example.FishCorp.Model.Pago;

public class PagoRequest {
    private Long pedidoId;
    private Double monto;
    private Pago.MetodoPago metodoPago;

    public Long getPedidoId() {
        return pedidoId;
    }

    public void setPedidoId(Long pedidoId) {
        this.pedidoId = pedidoId;
    }

    public Double getMonto() {
        return monto;
    }

    public void setMonto(Double monto) {
        this.monto = monto;
    }

    public Pago.MetodoPago getMetodoPago() {
        return metodoPago;
    }

    public void setMetodoPago(Pago.MetodoPago metodoPago) {
        this.metodoPago = metodoPago;
    }
}
