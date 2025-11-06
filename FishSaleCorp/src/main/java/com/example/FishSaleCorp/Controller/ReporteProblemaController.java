package com.example.FishSaleCorp.Controller;

import com.example.FishSaleCorp.DTO.ReporteProblemaDTO;
import com.example.FishSaleCorp.DTO.ReporteProblemaRequest;
import com.example.FishSaleCorp.Model.ReporteProblema;
import com.example.FishSaleCorp.Service.ReporteProblemaService;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.util.List;

@RestController
@RequestMapping("/api/problemas")
public class ReporteProblemaController {

    @Autowired
    private ReporteProblemaService service;

    @PostMapping("/reportes")
    @PreAuthorize("hasAnyRole('CLIENTE','PESCADOR')")
    public ResponseEntity<ReporteProblemaDTO> reportarProblema(
            @RequestParam("usuarioId") Long usuarioId,
            @RequestParam("descripcion") String descripcion,
            @RequestParam(value = "image", required = false) MultipartFile image) throws IOException {

        String imageUrl = null;
        if (image != null && !image.isEmpty()) {
            File uploadDir = new File("uploads/reportes");
            if (!uploadDir.exists()) uploadDir.mkdirs();

            String fileName = System.currentTimeMillis() + "_" + image.getOriginalFilename();
            File file = new File(uploadDir, fileName);
            image.transferTo(file);

            imageUrl = "/fishcorp.unicartagena/imagenes/" + fileName;
        }

        ReporteProblemaRequest request = new ReporteProblemaRequest();
        request.setUsuarioId(usuarioId);
        request.setDescripcion(descripcion);
        request.setImagenUrl(imageUrl);

        ReporteProblema creado = service.crearReporteProblema(request);
        return ResponseEntity.ok(new ReporteProblemaDTO(creado));
    }

    @GetMapping("/pendientes")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<ReporteProblemaDTO>> obtenerProblemasPendientes() {
        return ResponseEntity.ok(service.obtenerProblemasPendientes());
    }

    @GetMapping("/usuario/{usuarioId}")
    @PreAuthorize("hasAnyRole('CLIENTE','ADMIN')")
    public ResponseEntity<List<ReporteProblemaDTO>> getReportesPorUsuario(@PathVariable Long usuarioId) {
        return ResponseEntity.ok(service.obtenerReportesPorUsuario(usuarioId));
    }

    @PutMapping("/resolver/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ReporteProblemaDTO> resolverProblema(@PathVariable("id") Long id) {
        ReporteProblema actualizado = service.marcarComoResuelto(id);
        return ResponseEntity.ok(new ReporteProblemaDTO(actualizado));
    }
}
