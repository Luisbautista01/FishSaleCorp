package com.example.FishSaleCorp.Service;

import com.example.FishSaleCorp.Excepction.BadRequestException;
import com.example.FishSaleCorp.Excepction.InformacionIncompletaExcepcion;
import com.example.FishSaleCorp.Excepction.ResourceNotFoundException;
import com.example.FishSaleCorp.Model.Producto;
import com.example.FishSaleCorp.Repository.ProductoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class ProductoService {

    private final ProductoRepository productoRepository;

    @Autowired
    public ProductoService(ProductoRepository productoRepository) {
        this.productoRepository = productoRepository;
    }

    @Transactional
    public Producto crearProducto(Producto producto) {
        validarProducto(producto);
        if (productoRepository.existsByNombre(producto.getNombre())) {
            throw new IllegalArgumentException("Ya existe un producto con el nombre: " + producto.getNombre());
        }
        return productoRepository.save(producto);
    }

    @Transactional
    public Producto actualizarProducto(Long id, Producto nuevo) {
        validarProducto(nuevo);
        Producto existente = productoRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Producto no encontrado con ID: " + id));

        if (productoRepository.existsByNombre(nuevo.getNombre()) &&
                !existente.getNombre().equals(nuevo.getNombre())) {
            throw new BadRequestException("Ya existe un producto con el nombre: " + nuevo.getNombre());
        }

        existente.setNombre(nuevo.getNombre());
        existente.setPrecio(nuevo.getPrecio());
        existente.setCantidad(nuevo.getCantidad());
        existente.setCategoria(nuevo.getCategoria());
        existente.setImagen(nuevo.getImagen());
        existente.setPescador(nuevo.getPescador());
        existente.setDescuento(nuevo.getDescuento());

        return productoRepository.save(existente);
    }

    @Transactional
    public void eliminarProducto(Long id) {
        if (!productoRepository.existsById(id)) {
            throw new IllegalArgumentException("Producto no encontrado con ID: " + id);
        }
        productoRepository.deleteById(id);
    }

    @Transactional(readOnly = true)
    public List<Producto> listarTodos() {
        return productoRepository.findAll();
    }

    @Transactional(readOnly = true)
    public List<Producto> buscarPorNombre(String nombre) {
        return productoRepository.findByNombreContainingIgnoreCase(nombre);
    }

    @Transactional(readOnly = true)
    public List<Producto> listarPorPescador(Long pescadorId) {
        List<Producto> productos = productoRepository.findByPescadorId(pescadorId);
        if (productos.isEmpty()) {
            throw new ResourceNotFoundException("El pescador con ID " + pescadorId + " no tiene productos registrados.");
        }
        return productos;
    }

    private void validarProducto(Producto producto) {
        if (producto == null) {
            throw new InformacionIncompletaExcepcion("El producto no puede ser nulo.");
        }
        if (producto.getNombre() == null || producto.getNombre().isBlank()) {
            throw new InformacionIncompletaExcepcion("El nombre del producto no puede estar vacío.");
        }
        if (producto.getPrecio() == null || producto.getPrecio() <= 0) {
            throw new InformacionIncompletaExcepcion("El precio debe ser mayor a 0.");
        }
        if (producto.getCantidad() == null || producto.getCantidad() < 0) {
            throw new InformacionIncompletaExcepcion("La cantidad no puede ser negativa.");
        }
        if (producto.getPescador() == null) {
            throw new InformacionIncompletaExcepcion("El producto debe estar asociado a un pescador.");
        }
    }
}
