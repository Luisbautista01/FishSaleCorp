package com.example.FishSaleCorp.Validations;

import jakarta.validation.ConstraintValidator;
import jakarta.validation.ConstraintValidatorContext;

import java.util.List;

public class EmailDomainValidator implements ConstraintValidator<ValidEmailDomain, String> {

    private final List<String> dominiosPermitidos = List.of(
            "@gmail.com",
            "@hotmail.com",
            "@unicartagena.edu.co",
            "@admin.com",
            "@fishcorp.com",
            "@yahoo.com",
            "@outlook.com",
            "@icloud.com",
            "@cliente.com"
    );

    @Override
    public boolean isValid(String value, ConstraintValidatorContext context) {
        if (value == null || value.isBlank()) return false;

        return dominiosPermitidos.stream().anyMatch(value.toLowerCase()::endsWith);
    }
}
