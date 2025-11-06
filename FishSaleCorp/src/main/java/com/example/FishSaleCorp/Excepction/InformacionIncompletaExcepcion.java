package com.example.FishSaleCorp.Excepction;

public class InformacionIncompletaExcepcion extends RuntimeException {
    public InformacionIncompletaExcepcion(String mensaje) {
        super(mensaje);
    }
}
