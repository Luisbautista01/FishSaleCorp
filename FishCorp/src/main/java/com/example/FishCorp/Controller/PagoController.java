package com.example.FishCorp.Controller;

import com.example.FishCorp.DTO.PagoRequest;
import com.example.FishCorp.DTO.PagoResponse;
import com.example.FishCorp.DTO.TotalPorPescadorDTO;
import com.example.FishCorp.Model.Usuario;
import com.example.FishCorp.Service.PagoService;
import com.example.FishCorp.Repository.UsuarioRepository;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/pagos")
@CrossOrigin(origins = "http://localhost:5000")
public class PagoController {

    @Autowired
    private PagoService pagoService;

    @Autowired
    private UsuarioRepository usuarioRepository;

    private final DateTimeFormatter formatter = DateTimeFormatter.ISO_LOCAL_DATE_TIME;

    @PostMapping("/simular")
    @PreAuthorize("hasRole('CLIENTE')")
    public ResponseEntity<PagoResponse> simularPago(@RequestBody PagoRequest request) {
        return ResponseEntity.ok(PagoResponse.fromEntity(pagoService.simularPago(request)));
    }

    @GetMapping("/por-cliente")
    @PreAuthorize("hasAnyRole('CLIENTE','ADMIN','PESCADOR')")
    public ResponseEntity<List<PagoResponse>> listarPagosPorCliente(Authentication auth) {
        if (auth == null || auth.getName() == null) return ResponseEntity.ok(Collections.emptyList());

        Usuario usuario = usuarioRepository.findByEmail(auth.getName())
                                           .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));

        List<PagoResponse> pagos = pagoService.listarPagosPorCliente(usuario.getId());
        return ResponseEntity.ok(pagos != null ? pagos : Collections.emptyList());
    }

    @GetMapping("/por-cliente/{clienteId}")
    @PreAuthorize("hasAnyRole('CLIENTE','ADMIN','PESCADOR')")
    public ResponseEntity<List<PagoResponse>> listarPagosPorClienteId(@PathVariable("clienteId") Long clienteId) {
        return ResponseEntity.ok(pagoService.listarPagosPorCliente(clienteId));
    }

    @GetMapping("/por-pescador")
    @PreAuthorize("hasAnyRole('ADMIN','PESCADOR')")
    public ResponseEntity<List<PagoResponse>> listarPagosPorPescador(Authentication auth) {
        if (auth == null || auth.getName() == null) return ResponseEntity.ok(Collections.emptyList());

        Usuario usuario = usuarioRepository.findByEmail(auth.getName())
                                           .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));

        List<PagoResponse> pagos = pagoService.listarPagosPorPescador(usuario.getId());
        return ResponseEntity.ok(pagos != null ? pagos : Collections.emptyList());
    }

    @GetMapping("/por-pescador/{id}")
    @PreAuthorize("hasAnyRole('ADMIN','PESCADOR')")
    public ResponseEntity<List<Map<String, Object>>> obtenerPagosPorPescador(@PathVariable("id") Long id) {
        Usuario usuario = usuarioRepository.findById(id)
                                           .orElseThrow(() -> new RuntimeException("Pescador no encontrado con id " + id));

        if (usuario.getRol() != Usuario.Rol.PESCADOR)
            throw new RuntimeException("El id especificado no corresponde a un pescador");

        List<PagoResponse> pagos = pagoService.listarPagosPorPescador(id);
        if (pagos == null) pagos = new ArrayList<>();

        List<Map<String, Object>> resultado = pagos.stream().map(p -> {
            Map<String, Object> datos = new LinkedHashMap<>();
            datos.put("id", p.getId());
            datos.put("monto", p.getMonto());
            datos.put("estado", p.getEstado());
            datos.put("fechaCreacion", p.getFechaCreacion());
            datos.put("cliente", p.getCliente() != null ? p.getCliente() : "Desconocido");
            return datos;
        }).collect(Collectors.toList());

        return ResponseEntity.ok(resultado);
    }

    @GetMapping
    @PreAuthorize("hasAnyRole('ADMIN','PESCADOR')")
    public ResponseEntity<List<PagoResponse>> listarTodos() {
        List<PagoResponse> pagos = pagoService.listarTodos();
        return ResponseEntity.ok(pagos != null ? pagos : Collections.emptyList());
    }

    @GetMapping("/total-por-pescador")
    @PreAuthorize("hasAnyRole('ADMIN','PESCADOR')")
    public ResponseEntity<List<Map<String, Object>>> obtenerTotalPagadoPorPescador(Authentication auth) {
        Usuario usuario = usuarioRepository.findByEmail(auth.getName())
                                           .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));

        boolean esPescador = usuario.getRol() == Usuario.Rol.PESCADOR;
        List<TotalPorPescadorDTO> totalesDto = pagoService.obtenerTotalPagadoPorPescador(
                esPescador ? usuario.getId() : null,
                esPescador
        );

        List<Map<String, Object>> respuesta = totalesDto.stream().map(t -> {
            Map<String, Object> m = new LinkedHashMap<>();
            Long pescadorId = t.getPescadorId();
            String pescadorNombre = t.getPescador() != null ? t.getPescador() : "Desconocido";

            double totalDouble = t.getTotal() != null ? t.getTotal().doubleValue() : 0.0;
            long cantidadVentas = t.getCantidadVentas() != null ? t.getCantidadVentas() : 0L;
            double promedio = cantidadVentas > 0 ? totalDouble / cantidadVentas : 0.0;

            m.put("pescadorId", pescadorId);
            m.put("pescador", pescadorNombre);
            m.put("total", totalDouble);
            m.put("cantidadVentas", cantidadVentas);
            m.put("promedio", promedio);

            return m;
        }).collect(Collectors.toList());

        return ResponseEntity.ok(respuesta);
    }

    @GetMapping("/total-por-pescador/rango")
    @PreAuthorize("hasAnyRole('ADMIN','PESCADOR')")
    public ResponseEntity<?> totalPorPescadorEnRango(
            @RequestParam(required = false) String inicio,
            @RequestParam(required = false) String fin
    ) {
        LocalDateTime fechaInicio = (inicio != null) ? LocalDateTime.parse(inicio, formatter) : null;
        LocalDateTime fechaFin = (fin != null) ? LocalDateTime.parse(fin, formatter) : null;
        return ResponseEntity.ok(pagoService.obtenerTotalPagadoPorPescadorEnRango(fechaInicio, fechaFin));
    }

    @GetMapping("/{id}/recibo")
    @PreAuthorize("hasAnyRole('CLIENTE','ADMIN','PESCADOR')")
    public ResponseEntity<byte[]> generarRecibo(@PathVariable("id") Long id) {
        byte[] pdfBytes = pagoService.generarReciboPago(id);
        return ResponseEntity.ok()
                .header("Content-Disposition", "attachment; filename=recibo_pago_" + id + ".pdf")
                .contentType(org.springframework.http.MediaType.APPLICATION_PDF)
                .body(pdfBytes);
    }
}
