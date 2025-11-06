package com.example.FishSaleCorp.Validations;

import jakarta.validation.Constraint;
import jakarta.validation.Payload;

import java.lang.annotation.*;

@Documented
@Constraint(validatedBy = RolValidator.class)
@Target({ElementType.FIELD})
@Retention(RetentionPolicy.RUNTIME)
public @interface ValidRol {
    String message() default "Rol inválido. Usa CLIENTE, PESCADOR o ADMIN";
    Class<?>[] groups() default {};
    Class<? extends Payload>[] payload() default {};
}
