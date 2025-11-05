package com.example.FishCorp.Excepction;

public class PagoNoEncontradoException extends RuntimeException {
    public PagoNoEncontradoException(String mensaje) {
        super(mensaje);
    }
}