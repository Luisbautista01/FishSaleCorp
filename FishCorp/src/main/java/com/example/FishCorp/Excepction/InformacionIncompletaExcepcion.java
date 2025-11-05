package com.example.FishCorp.Excepction;

public class InformacionIncompletaExcepcion extends RuntimeException {
    public InformacionIncompletaExcepcion(String mensaje) {
        super(mensaje);
    }
}
