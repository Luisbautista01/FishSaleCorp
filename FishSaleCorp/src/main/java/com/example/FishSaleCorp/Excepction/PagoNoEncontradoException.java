package com.example.FishSaleCorp.Excepction;

public class PagoNoEncontradoException extends RuntimeException {
    public PagoNoEncontradoException(String mensaje) {
        super(mensaje);
    }
}