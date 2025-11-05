package com.example.FishCorp.Repository;

import com.example.FishCorp.DTO.ReporteProblemaDTO;
import com.example.FishCorp.Model.ReporteProblema;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;

public interface ReporteProblemaRepository extends JpaRepository<ReporteProblema, Long> {

   @Query("SELECT new com.example.FishCorp.DTO.ReporteProblemaDTO(" +
           "r.id, r.descripcion, r.imagenUrl, r.usuario.id, r.usuario.nombre, " +
           "r.fechaSolicitud, r.resolver) " +
           "FROM ReporteProblema r WHERE r.usuario.id = :usuarioId ORDER BY r.fechaSolicitud DESC")
    List<ReporteProblemaDTO> findReportesPorUsuario(Long usuarioId);

    List<ReporteProblema> findByResolverFalse();
}
