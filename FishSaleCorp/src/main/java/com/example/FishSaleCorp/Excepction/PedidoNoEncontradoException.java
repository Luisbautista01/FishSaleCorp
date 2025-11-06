package com.example.FishSaleCorp.Excepction;

public class PedidoNoEncontradoException extends RuntimeException {
    public PedidoNoEncontradoException(String mensaje) {
        super(mensaje);
    }
}