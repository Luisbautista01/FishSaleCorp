package com.example.FishCorp.Excepction;

public class RolInvalidoException extends RuntimeException {
    public RolInvalidoException(String mensaje) {
        super(mensaje);
    }
}