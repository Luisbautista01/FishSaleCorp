package com.example.FishCorp.Repository;

import com.example.FishCorp.Model.Pago;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface PagoRepository extends JpaRepository<Pago, Long> {

   @Query("""
        SELECT p FROM Pago p
        JOIN FETCH p.pedido ped
        LEFT JOIN FETCH ped.cliente
        LEFT JOIN FETCH ped.producto prod
        LEFT JOIN FETCH prod.pescador
        WHERE ped.cliente.id = :clienteId
    """)
    List<Pago> findByPedido_Cliente_Id(@Param("clienteId") Long clienteId);
    @Query("""
        SELECT DISTINCT p FROM Pago p
        LEFT JOIN FETCH p.pedido ped
        LEFT JOIN FETCH ped.cliente c
        LEFT JOIN FETCH ped.producto prod
        LEFT JOIN FETCH prod.pescador pesc
        WHERE pesc IS NOT NULL AND pesc.id = :pescadorId
    """)
    List<Pago> findByPedido_Producto_Pescador_Id(@Param("pescadorId") Long pescadorId);

    @Query("""
        SELECT p.pedido.producto.pescador.nombre, SUM(p.monto), COUNT(p.id)
        FROM Pago p
        WHERE p.estado = 'APROBADO'
        GROUP BY p.pedido.producto.pescador.nombre
    """)
    List<Object[]> totalPagadoPorPescador();

    @Query("""
        SELECT p.pedido.producto.pescador.nombre, SUM(p.monto), COUNT(p.id)
        FROM Pago p
        WHERE p.estado = 'APROBADO'
          AND (:inicio IS NULL OR p.fechaCreacion >= :inicio)
          AND (:fin IS NULL OR p.fechaCreacion <= :fin)
        GROUP BY p.pedido.producto.pescador.nombre
    """)
    List<Object[]> totalPagadoPorPescadorEnRango(@Param("inicio") LocalDateTime inicio, @Param("fin") LocalDateTime fin);

    @Query("""
        SELECT 
            p.pedido.producto.pescador.id AS pescadorId,
            p.pedido.producto.pescador.nombre AS pescadorNombre,
            SUM(p.monto) AS total,
            COUNT(p.id) AS cantidadVentas
        FROM Pago p
        WHERE p.estado = 'APROBADO'
        GROUP BY p.pedido.producto.pescador.id, p.pedido.producto.pescador.nombre
    """)
    List<Object[]> obtenerTotalesPorPescador();

    @Query("""
        SELECT 
            p.pedido.producto.pescador.id AS pescadorId,
            p.pedido.producto.pescador.nombre AS pescadorNombre,
            SUM(p.monto) AS total,
            COUNT(p.id) AS cantidadVentas
        FROM Pago p
        WHERE p.estado = 'APROBADO'
        AND p.pedido.producto.pescador.id = :pescadorId
        GROUP BY p.pedido.producto.pescador.id, p.pedido.producto.pescador.nombre
    """)
    List<Object[]> obtenerTotalesPorPescadorEspecifico(@Param("pescadorId") Long pescadorId);

}
