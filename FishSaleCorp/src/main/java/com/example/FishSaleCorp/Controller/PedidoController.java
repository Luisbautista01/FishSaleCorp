package com.example.FishSaleCorp.Controller;

import com.example.FishSaleCorp.DTO.PedidoCompuestoRequest;
import com.example.FishSaleCorp.DTO.PedidoRequest;
import com.example.FishSaleCorp.DTO.PedidoResponse;
import com.example.FishSaleCorp.Excepction.BadRequestException;
import com.example.FishSaleCorp.Model.Pedido;
import com.example.FishSaleCorp.Service.PedidoService;

import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.security.Principal;
import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@RestController
@RequestMapping("/api/pedidos")
@CrossOrigin(origins = "http://localhost:5000")
public class PedidoController {

    private static final Logger logger = LoggerFactory.getLogger(PedidoController.class);

    @Autowired
    private PedidoService pedidoService;

    @PostMapping
    @PreAuthorize("hasRole('CLIENTE')")
    public PedidoResponse crearPedido(@Valid @RequestBody PedidoRequest request, Principal principal) {
        logger.info("Creando pedido para el cliente: {}", principal.getName());
        PedidoResponse response = pedidoService.crearPedido(request, principal);
        logger.info("Pedido creado exitosamente con ID: {}", response.getId());
        return response;
    }

    @PostMapping("/compuesto")
    @PreAuthorize("hasRole('CLIENTE')")
    public List<PedidoResponse> crearPedidoCompuesto(
            @Valid @RequestBody PedidoCompuestoRequest request, Principal principal) {
        logger.info("Creando pedido compuesto para el cliente: {}", principal.getName());
        return pedidoService.crearPedidoCompuesto(request, principal);
    }

    @PutMapping("/estado/{id}")
    @PreAuthorize("hasAnyRole('ADMIN','PESCADOR')")
    public PedidoResponse actualizarEstado(@PathVariable("id") Long id,
                                        @RequestParam String estado,
                                        Principal principal) {
        logger.info("Actualizando estado del pedido con ID: {} a {} por el usuario: {}", id, estado, principal.getName());
        
        Pedido.EstadoPedido estadoEnum;
        try {
            estadoEnum = Pedido.EstadoPedido.valueOf(estado.toUpperCase());
        } catch (IllegalArgumentException e) {
            throw new BadRequestException("Estado inválido: " + estado);
        }

        PedidoResponse response = pedidoService.actualizarEstado(id, estadoEnum, principal);
        logger.info("Estado actualizado exitosamente para pedido con ID: {}", id);
        return response;
    }

    @GetMapping
    @PreAuthorize("hasAnyRole('CLIENTE','ADMIN','PESCADOR')")
    public List<PedidoResponse> listarPedidos() {
        logger.info("Listando todos los pedidos");
        return pedidoService.listarPedidos();
    }

    @GetMapping("/cliente")
    @PreAuthorize("hasAnyRole('CLIENTE','ADMIN','PESCADOR')")
    public List<PedidoResponse> listarPedidosDelCliente(Principal principal) {
        logger.info("Listando pedidos para el cliente: {}", principal.getName());
        return pedidoService.listarPedidosDelCliente(principal);
    }

    @GetMapping("/cliente/{id}")
    @PreAuthorize("hasAnyRole('CLIENTE','ADMIN','PESCADOR')")
    public List<PedidoResponse> listarPedidosPorClienteId(@PathVariable("id") Long id) {
        logger.info("Listando pedidos por ID de cliente: {}", id);
        return pedidoService.listarPedidosPorClienteId(id);
    }

    @GetMapping("/pescador/{id}")
    @PreAuthorize("hasAnyRole('ADMIN','PESCADOR')")
    public List<PedidoResponse> listarPedidosPorPescadorId(@PathVariable("id") Long id) {
        logger.info("Listando pedidos por ID de pescador: {}", id);
        return pedidoService.listarPedidosPorPescadorId(id);
    }

    @GetMapping("/buscar")
    @PreAuthorize("hasAnyRole('CLIENTE','ADMIN','PESCADOR')")
    public Page<PedidoResponse> buscarPedidos(
            @RequestParam(required = false) String nombre,
            @RequestParam(required = false) String correo,
            @RequestParam(required = false) Pedido.EstadoPedido estado,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "5") int size) {
        logger.info("Buscando pedidos con filtros - Nombre: {}, Correo: {}, Estado: {}", nombre, correo, estado);
        return pedidoService.buscarPedidos(nombre, correo, estado, page, size);
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN','PESCADOR')")
    public void eliminarPedido(@PathVariable Long id) {
        logger.warn("Eliminando pedido con ID: {}", id);
        pedidoService.eliminarPedido(id);
        logger.info("Pedido eliminado exitosamente con ID: {}", id);
    }

    @GetMapping("/historial")
    @PreAuthorize("hasAnyRole('ADMIN','PESCADOR')")
    public Page<PedidoResponse> historialPedidosPorCliente(
            Principal principal,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "5") int size) {
        logger.info("Consultando historial de pedidos para el cliente: {}", principal.getName());
        return pedidoService.historialPedidosPorCliente(principal, page, size);
    }
}
