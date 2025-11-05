package com.example.FishCorp.Validations;

import com.example.FishCorp.Model.Usuario;
import jakarta.validation.ConstraintValidator;
import jakarta.validation.ConstraintValidatorContext;

import java.util.Arrays;

public class RolValidator implements ConstraintValidator<ValidRol, String> {

    @Override
    public boolean isValid(String value, ConstraintValidatorContext context) {
        if (value == null || value.isBlank()) return false;

        return Arrays.stream(Usuario.Rol.values())
                .anyMatch(rol -> rol.name().equalsIgnoreCase(value));
    }
}
