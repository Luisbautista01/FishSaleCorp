package com.example.FishCorp.Repository;

import com.example.FishCorp.Model.Producto;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface ProductoRepository extends JpaRepository <Producto, Long> {
    boolean existsByNombre (String nombre);
    List<Producto> findByNombreContainingIgnoreCase(String nombre);

    @Query("SELECT p FROM Producto p WHERE p.pescador.id = :pescadorId")
    List<Producto> findByPescadorId(@Param("pescadorId") Long pescadorId);
}
