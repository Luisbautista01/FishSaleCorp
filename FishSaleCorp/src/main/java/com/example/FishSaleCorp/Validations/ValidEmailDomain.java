package com.example.FishSaleCorp.Validations;

import jakarta.validation.Constraint;
import jakarta.validation.Payload;

import java.lang.annotation.*;

@Documented
@Constraint(validatedBy = EmailDomainValidator.class)
@Target({ElementType.FIELD})
@Retention(RetentionPolicy.RUNTIME)
public @interface ValidEmailDomain {
    String message() default "El email debe terminar en @gmail.com, @hotmail.com, @cliente.com";

    Class<?>[] groups() default {};

    Class<? extends Payload>[] payload() default {};
}
