package com.example.FishCorp.Repository;

import com.example.FishCorp.Model.Pedido;

import java.util.List;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

public interface PedidoRepository extends JpaRepository<Pedido, Long> {
    java.util.List<Pedido> findByClienteId(Long clienteId);

    Page<Pedido> findByClienteId(Long clienteId, Pageable pageable);
    
    List<Pedido> findByPescadorId(Long pescadorId);

    Page<Pedido> findByClienteNombreContainingIgnoreCase(String nombre, Pageable pageable);

    Page<Pedido> findByEstadoAndClienteNombreContainingIgnoreCaseOrEstadoAndClienteEmailContainingIgnoreCase(
            Pedido.EstadoPedido estado1, String nombre,
            Pedido.EstadoPedido estado2, String email,
            Pageable pageable);

    Page<Pedido> findByEstado(Pedido.EstadoPedido estado, Pageable pageable);

    Page<Pedido> findByClienteEmailContainingIgnoreCase(String email, Pageable pageable);
}
