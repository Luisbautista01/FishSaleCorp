package com.example.FishCorp.Service;

import com.example.FishCorp.Controller.AuthController;
import com.example.FishCorp.DTO.PedidoCompuestoRequest;
import com.example.FishCorp.DTO.PedidoRequest;
import com.example.FishCorp.DTO.PedidoResponse;
import com.example.FishCorp.Excepction.BadRequestException;
import com.example.FishCorp.Excepction.ResourceNotFoundException;
import com.example.FishCorp.Model.Pedido;
import com.example.FishCorp.Model.Pedido.EstadoPedido;
import com.example.FishCorp.Model.Producto;
import com.example.FishCorp.Model.Usuario;
import com.example.FishCorp.Repository.PedidoRepository;
import com.example.FishCorp.Repository.ProductoRepository;
import com.example.FishCorp.Repository.UsuarioRepository;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.security.Principal;
import java.util.List;
import java.util.stream.Collectors;

import org.springframework.security.access.AccessDeniedException;

@Service
public class PedidoService {

    private final PedidoRepository pedidoRepository;
    private final ProductoRepository productoRepository;
    private final UsuarioRepository usuarioRepository;
    private static final Logger logger = LoggerFactory.getLogger(AuthController.class);

    @Autowired
    public PedidoService(PedidoRepository pedidoRepository,
                         ProductoRepository productoRepository,
                         UsuarioRepository usuarioRepository) {
        this.pedidoRepository = pedidoRepository;
        this.productoRepository = productoRepository;
        this.usuarioRepository = usuarioRepository;
    }

    @Transactional
    public PedidoResponse crearPedido(PedidoRequest request, Principal principal) {
        Usuario cliente = usuarioRepository.findByEmail(principal.getName())
                .orElseThrow(() -> new ResourceNotFoundException("Cliente no encontrado"));

        Producto producto = productoRepository.findById(request.getProductoId())
                .orElseThrow(() -> new ResourceNotFoundException("Producto no encontrado"));

        if (producto.getCantidad() < request.getCantidad()) {
            throw new BadRequestException("No hay suficiente stock para el producto: " + producto.getNombre());
        }

        Usuario pescador = producto.getPescador();
        if (pescador == null) {
            throw new BadRequestException("El producto no tiene un pescador asignado");
        }

        Pedido pedido = new Pedido();
        pedido.setCliente(cliente);
        pedido.setProducto(producto);
        pedido.setPescador(pescador);
        pedido.setCantidad(request.getCantidad());
        pedido.setEstado(Pedido.EstadoPedido.PENDIENTE);
        pedido.setFechaCreacion(java.time.LocalDateTime.now());
        pedido.setDireccion(request.getDireccion());

        logger.info("Nuevo pedido creado por {} para el producto {} (pescador asignado: {})",
                cliente.getEmail(), producto.getNombre(), pescador.getEmail());

        return PedidoResponse.fromEntity(pedidoRepository.save(pedido));
    }

    @Transactional
    public List<PedidoResponse> crearPedidoCompuesto(PedidoCompuestoRequest request, Principal principal) {
        Usuario cliente = usuarioRepository.findByEmail(principal.getName())
                .orElseThrow(() -> new ResourceNotFoundException("Cliente no encontrado"));

        return request.getProductos().stream().map(pc -> {
            Producto producto = productoRepository.findById(pc.getProductoId())
                    .orElseThrow(() -> new ResourceNotFoundException("Producto no encontrado: " + pc.getProductoId()));

            if (producto.getCantidad() < pc.getCantidad()) {
                throw new BadRequestException("No hay suficiente stock para el producto: " + producto.getNombre());
            }

            Pedido pedido = new Pedido();
            pedido.setCliente(cliente);
            pedido.setProducto(producto);
            pedido.setPescador(producto.getPescador());
            pedido.setCantidad(pc.getCantidad());
            pedido.setEstado(Pedido.EstadoPedido.PENDIENTE);
            pedido.setFechaCreacion(java.time.LocalDateTime.now());
            pedido.setDireccion(request.getDireccion());

            logger.info("Pedido compuesto creado: cliente={} producto={} pescador={}",
                    cliente.getEmail(), producto.getNombre(), producto.getPescador().getEmail());

            return PedidoResponse.fromEntity(pedidoRepository.save(pedido));
        }).toList();
    }

    @Transactional
    public PedidoResponse actualizarEstado(Long id, EstadoPedido estadoEnum, Principal principal) {
        Pedido pedido = pedidoRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Pedido no encontrado con ID: " + id));

        Usuario usuario = usuarioRepository.findByEmail(principal.getName())
                .orElseThrow(() -> new ResourceNotFoundException("Usuario no encontrado"));

        if (usuario.getRol() == Usuario.Rol.ADMIN) {
            logger.info("ADMIN {} cambió el estado del pedido {} de {} a {}",
                    usuario.getEmail(), id, pedido.getEstado(), estadoEnum);
            pedido.setEstado(estadoEnum);
        }

        else if (usuario.getRol() == Usuario.Rol.PESCADOR) {
            if (!pedido.getPescador().getId().equals(usuario.getId())) {
                logger.warn("PESCADOR {} intentó modificar un pedido ajeno (pedido {}, pescador asignado: {})",
                        usuario.getEmail(), id, pedido.getPescador().getEmail());
                throw new AccessDeniedException("No tienes permiso para modificar pedidos de otro pescador.");
            }

            if (estadoEnum != Pedido.EstadoPedido.ENTREGADO) {
                logger.warn("PESCADOR {} intentó cambiar pedido {} a {}, pero solo puede marcar como ENTREGADO.",
                        usuario.getEmail(), id, estadoEnum);
                throw new AccessDeniedException("Solo puedes marcar tus pedidos como ENTREGADO.");
            }

            logger.info("PESCADOR {} marcó el pedido {} como ENTREGADO.",
                    usuario.getEmail(), id);
            pedido.setEstado(Pedido.EstadoPedido.ENTREGADO);
        } else {
            logger.warn("Usuario {} (rol={}) intentó modificar un pedido sin permisos.", usuario.getEmail(), usuario.getRol());
            throw new AccessDeniedException("No tienes permiso para actualizar el estado del pedido.");
        }

        return PedidoResponse.fromEntity(pedidoRepository.save(pedido));
    }

    @Transactional(readOnly = true)
    public List<PedidoResponse> listarPedidos() {
        return pedidoRepository.findAll().stream()
                .map(PedidoResponse::fromEntity)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<PedidoResponse> listarPedidosDelCliente(Principal principal) {
        Usuario cliente = usuarioRepository.findByEmail(principal.getName())
                .orElseThrow(() -> new ResourceNotFoundException("Cliente no encontrado"));
        return pedidoRepository.findByClienteId(cliente.getId()).stream()
                .map(PedidoResponse::fromEntity)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<PedidoResponse> listarPedidosPorClienteId(Long id) {
        usuarioRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Cliente no encontrado con ID: " + id));
        return pedidoRepository.findByClienteId(id).stream()
                .map(PedidoResponse::fromEntity)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<PedidoResponse> listarPedidosPorPescadorId(Long pescadorId) {
        usuarioRepository.findById(pescadorId)
                .orElseThrow(() -> new ResourceNotFoundException("Pescador no encontrado con ID: " + pescadorId));

        return pedidoRepository.findByPescadorId(pescadorId)
            .stream()
            .map(PedidoResponse::fromEntity)
            .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public Page<PedidoResponse> buscarPedidos(String nombre, String correo, Pedido.EstadoPedido estado,
                                              int page, int size) {
        Page<Pedido> pedidos;

        if (nombre != null && correo != null && estado != null) {
            pedidos = pedidoRepository.findByEstadoAndClienteNombreContainingIgnoreCaseOrEstadoAndClienteEmailContainingIgnoreCase(
                    estado, nombre, estado, correo, PageRequest.of(page, size));
        } else if (nombre != null) {
            pedidos = pedidoRepository.findByClienteNombreContainingIgnoreCase(nombre, PageRequest.of(page, size));
        } else if (correo != null) {
            pedidos = pedidoRepository.findByClienteEmailContainingIgnoreCase(correo, PageRequest.of(page, size));
        } else if (estado != null) {
            pedidos = pedidoRepository.findByEstado(estado, PageRequest.of(page, size));
        } else {
            pedidos = pedidoRepository.findAll(PageRequest.of(page, size));
        }

        return pedidos.map(PedidoResponse::fromEntity);
    }

    @Transactional
    public void eliminarPedido(Long id) {
        Pedido pedido = pedidoRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Pedido no encontrado con ID: " + id));

        // Devolver cantidad al stock
        Producto producto = pedido.getProducto();
        producto.setCantidad(producto.getCantidad() + pedido.getCantidad());
        productoRepository.save(producto);

        pedidoRepository.deleteById(id);
    }

    @Transactional(readOnly = true)
    public Page<PedidoResponse> historialPedidosPorCliente(Principal principal, int page, int size) {
        Usuario cliente = usuarioRepository.findByEmail(principal.getName())
                .orElseThrow(() -> new ResourceNotFoundException("Cliente no encontrado"));
        return pedidoRepository.findByClienteId(cliente.getId(), PageRequest.of(page, size))
                .map(PedidoResponse::fromEntity);
    }
}
