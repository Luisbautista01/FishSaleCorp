package com.example.FishSaleCorp.Controller;

import com.example.FishSaleCorp.DTO.ProductoRequest;
import com.example.FishSaleCorp.Model.Producto;
import com.example.FishSaleCorp.Model.Usuario;
import com.example.FishSaleCorp.Repository.UsuarioRepository;
import com.example.FishSaleCorp.Service.ProductoService;
import com.example.FishSaleCorp.Repository.ProductoRepository;

import com.example.FishSaleCorp.Excepction.BadRequestException;
import com.example.FishSaleCorp.Excepction.ResourceNotFoundException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/productos")
@CrossOrigin(origins = "http://localhost:5000")
public class ProductoController {

    @Autowired
    private ProductoService productoService;

    @Autowired
    private UsuarioRepository usuarioRepository;

    @Autowired
    private ProductoRepository productoRepository;

    @PostMapping
    @PreAuthorize("hasRole('ADMIN') or hasRole('PESCADOR')")
    public Producto crear(@RequestBody ProductoRequest req) {
        if (req.getPescadorId() == null) {
            throw new BadRequestException("El campo 'pescadorId' es obligatorio al crear un producto.");
        }

        Usuario pescador = usuarioRepository.findById(req.getPescadorId())
                .orElseThrow(() -> new ResourceNotFoundException("Pescador no encontrado con ID: " + req.getPescadorId()));

        Producto p = new Producto();
        p.setNombre(req.getNombre());
        p.setPrecio(req.getPrecio());
        p.setCantidad(req.getCantidad());
        p.setCategoria(req.getCategoria());
        p.setImagen(req.getImagen());
        p.setPescador(pescador);
        p.setDescuento(req.getDescuento()); 
        return productoService.crearProducto(p);
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN') or hasRole('PESCADOR')")
    public Producto actualizar(@PathVariable("id") Long id, @RequestBody ProductoRequest req) {

        Producto existente = productoRepository.findById(id)
            .orElseThrow(() -> new ResourceNotFoundException("Producto no encontrado con ID: " + id));

        Usuario pescador;
        if (req.getPescadorId() != null) {
            pescador = usuarioRepository.findById(req.getPescadorId())
                    .orElseThrow(() -> new ResourceNotFoundException("Pescador no encontrado con ID: " + req.getPescadorId()));
        } else {
            pescador = existente.getPescador(); // mantiene el actual
        }

        existente.setNombre(req.getNombre());
        existente.setPrecio(req.getPrecio());
        existente.setCantidad(req.getCantidad());
        existente.setCategoria(req.getCategoria());
        existente.setImagen(req.getImagen());
        existente.setDescuento(req.getDescuento());
        existente.setPescador(pescador);

        return productoService.actualizarProducto(id, existente);
    }


    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public void eliminar(@PathVariable("id") Long id) {
        productoService.eliminarProducto(id);
    }

    @GetMapping
    @PreAuthorize("hasAnyRole('CLIENTE','PESCADOR','ADMIN')")
    public List<Producto> listarTodos() {
        return productoService.listarTodos();
    }

    @GetMapping("/buscar_por_Nombre")
    @PreAuthorize("hasAnyRole('CLIENTE','PESCADOR','ADMIN')")
    public List<Producto> buscarPorNombre(@RequestParam("nombre") String nombre) {
        return productoService.buscarPorNombre(nombre);
    }

    @PostMapping("/subir-imagen")
    @PreAuthorize("hasRole('ADMIN') or hasRole('PESCADOR')")
    public Map<String, String> subirImagen(@RequestParam("archivo") MultipartFile archivo) throws IOException {
        if (archivo.isEmpty()) throw new BadRequestException("No se subió ningún archivo");

        // Ruta donde se guardarán las imágenes
        String carpeta = "uploads/productos/";
        File dir = new File(carpeta);
        if (!dir.exists()) dir.mkdirs();

        String nombreArchivo = UUID.randomUUID() + "_" + archivo.getOriginalFilename();
        Path rutaArchivo = Paths.get(carpeta, nombreArchivo);
        Files.copy(archivo.getInputStream(), rutaArchivo, StandardCopyOption.REPLACE_EXISTING);

        // Devuelve la URL completa que el frontend puede usar
        String url = "http://localhost:8080/fishcorp.unicartagena/imagenes/" + nombreArchivo;
        return Map.of("url", url);
    }

    @GetMapping("/pescador/{id}")
    @PreAuthorize("hasAnyRole('PESCADOR', 'ADMIN')")
    public List<Producto> listarPorPescador(@PathVariable("id") Long id) {
        return productoService.listarPorPescador(id);
    }
}
