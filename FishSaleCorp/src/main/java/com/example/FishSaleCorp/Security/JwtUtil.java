package com.example.FishSaleCorp.Security;

import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.security.Keys;
import org.springframework.stereotype.Component;

import java.security.Key;
import java.util.Date;

@Component
public class JwtUtil {

    private static final String SECRET_KEY = "FishCorpSecretKeySuperSegura2025_LuisBautista2004";
    private final Key key = Keys.hmacShaKeyFor(SECRET_KEY.getBytes());
    private static final long EXPIRATION_TIME = 1000 * 60 * 60; 

    public String generarToken(String email, String rol) {

        if (rol.startsWith("ROLE_")) {
            rol = rol.substring(5);
        }

        return Jwts.builder()
                .setSubject(email)
                .claim("rol", rol) 
                .setIssuedAt(new Date())
                .setExpiration(new Date(System.currentTimeMillis() + EXPIRATION_TIME))
                .signWith(key, SignatureAlgorithm.HS256)
                .compact();
    }

    public Key getKey() {
        return key;
    }
}
