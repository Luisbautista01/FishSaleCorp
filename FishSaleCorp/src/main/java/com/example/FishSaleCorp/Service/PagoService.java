package com.example.FishSaleCorp.Service;

import com.example.FishSaleCorp.DTO.PagoResponse;
import com.example.FishSaleCorp.DTO.TotalPorPescadorDTO;
import com.example.FishSaleCorp.Excepction.PagoNoEncontradoException;
import com.example.FishSaleCorp.Excepction.PedidoNoEncontradoException;
import com.example.FishSaleCorp.Excepction.StockInsuficienteException;
import com.example.FishSaleCorp.DTO.PagoRequest;
import com.example.FishSaleCorp.Model.Pago;
import com.example.FishSaleCorp.Model.Pedido;
import com.example.FishSaleCorp.Model.Producto;
import com.example.FishSaleCorp.Repository.PagoRepository;
import com.example.FishSaleCorp.Repository.PedidoRepository;
import com.example.FishSaleCorp.Repository.ProductoRepository;
import com.itextpdf.text.Document;
import com.itextpdf.text.Font;
import com.itextpdf.text.PageSize;
import com.itextpdf.text.Paragraph;
import com.itextpdf.text.pdf.PdfWriter;
import com.itextpdf.text.pdf.draw.LineSeparator;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.io.ByteArrayOutputStream;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@Service
public class PagoService {

    @Autowired private PagoRepository pagoRepository;
    @Autowired private PedidoRepository pedidoRepository;
    @Autowired private ProductoRepository productoRepository;

    @Transactional
    public Pago simularPago(PagoRequest request) {
        Objects.requireNonNull(request, "El request de pago no puede ser nulo");
        Objects.requireNonNull(request.getPedidoId(), "El pedidoId es obligatorio");
        Objects.requireNonNull(request.getMetodoPago(), "El metodo de pago es obligatorio");
        Objects.requireNonNull(request.getMonto(), "El monto es obligatorio");

        Pedido pedido = pedidoRepository.findById(request.getPedidoId())
                .orElseThrow(() -> new PedidoNoEncontradoException("Pedido no encontrado"));

        String referencia = "SIM-" + UUID.randomUUID().toString().substring(0, 8);
        Pago.EstadoPago estado = Math.random() < 0.9 ? Pago.EstadoPago.APROBADO : Pago.EstadoPago.RECHAZADO;

        Pago pago = new Pago(pedido, referencia, request.getMetodoPago(), request.getMonto());
        pago.setEstado(estado);
        pago.setFechaCreacion(LocalDateTime.now());
        pago = pagoRepository.save(pago);

        if (estado == Pago.EstadoPago.APROBADO) {
            actualizarStockYPedido(pedido);
        }

        return pago;
    }

    @SuppressWarnings("unused")
    private void actualizarStockYPedido(Pedido pedido) {
        Objects.requireNonNull(pedido, "El pedido no puede ser nulo");
        Producto producto = pedido.getProducto();
        Objects.requireNonNull(producto, "El producto del pedido no puede ser nulo");

        Integer cantidadProducto = producto.getCantidad();
        Integer cantidadPedido = pedido.getCantidad();
        if (cantidadProducto == null) cantidadProducto = 0;
        if (cantidadPedido == null) cantidadPedido = 0;

        if (cantidadProducto < cantidadPedido) {
            throw new StockInsuficienteException("Stock insuficiente para el producto: " + Optional.ofNullable(producto.getNombre()).orElse("<sin-nombre>"));
        }

        producto.setCantidad(cantidadProducto - cantidadPedido);
        pedido.setEstado(Pedido.EstadoPedido.ENVIADO);
        productoRepository.save(producto);
        pedidoRepository.save(pedido);
    }

    @Transactional(readOnly = true)
    public List<PagoResponse> listarPagosPorCliente(Long clienteId) {
    if (clienteId == null) return Collections.emptyList();
    List<Pago> pagos = pagoRepository.findByPedido_Cliente_Id(clienteId);
    return pagos == null ? Collections.emptyList()
        : pagos.stream().map(PagoResponse::fromEntity).collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<PagoResponse> listarPagosPorPescador(Long pescadorId) {
        if (pescadorId == null) return Collections.emptyList();
        List<Pago> pagos = pagoRepository.findByPedido_Producto_Pescador_Id(pescadorId);
        if (pagos == null) return Collections.emptyList();

        return pagos.stream()
                .filter(p -> EnumSet.of(Pago.EstadoPago.APROBADO, Pago.EstadoPago.RECHAZADO, Pago.EstadoPago.PENDIENTE).contains(p.getEstado()))
                .map(PagoResponse::fromEntity)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<PagoResponse> listarTodos() {
        List<Pago> pagos = pagoRepository.findAll();
        return pagos == null ? Collections.emptyList()
                : pagos.stream().map(PagoResponse::fromEntity).collect(Collectors.toList());
    }

    public List<TotalPorPescadorDTO> obtenerTotalPagadoPorPescador(Long pescadorId, boolean esPescador) {
        List<Object[]> resultados = esPescador && pescadorId != null
                ? pagoRepository.obtenerTotalesPorPescadorEspecifico(pescadorId)
                : pagoRepository.obtenerTotalesPorPescador();
        if (resultados == null) return Collections.emptyList();

        return resultados.stream()
                .map(r -> {
                    long id = r[0] == null ? 0L : ((Number) r[0]).longValue();
                    String nombre = r[1] == null ? "" : r[1].toString();
                    BigDecimal total = BigDecimal.ZERO;
                    if (r[2] instanceof Number) {
                        total = BigDecimal.valueOf(((Number) r[2]).doubleValue());
                    } else if (r[2] != null) {
                        try {
                            total = new BigDecimal(r[2].toString());
                        } catch (NumberFormatException ignored) {
                            total = BigDecimal.ZERO;
                        }
                    }
                    long cantidad = r[3] == null ? 0L : ((Number) r[3]).longValue();
                    return new TotalPorPescadorDTO(id, nombre, total, cantidad);
                })
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<Map<String, Object>> obtenerTotalPagadoPorPescadorEnRango(LocalDateTime inicio, LocalDateTime fin) {
    List<Object[]> resultados = pagoRepository.totalPagadoPorPescadorEnRango(inicio, fin);
    if (resultados == null) return Collections.emptyList();

    return resultados.stream()
        .map(obj -> Map.of(
            "pescador", obj.length > 0 ? obj[0] : null,
            "total", obj.length > 1 ? obj[1] : null,
            "cantidadVentas", obj.length > 2 ? obj[2] : null
        ))
        .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public byte[] generarReciboPago(Long pagoId) {
        Pago pago = pagoRepository.findById(pagoId)
                .orElseThrow(() -> new PagoNoEncontradoException("Pago no encontrado"));

        try (ByteArrayOutputStream out = new ByteArrayOutputStream()) {
            Document document = new Document(PageSize.A5, 36, 36, 36, 36);
            PdfWriter.getInstance(document, out);
            document.open();

            Font tituloFont = new Font(Font.FontFamily.HELVETICA, 16, Font.BOLD);
            Font textoFont = new Font(Font.FontFamily.HELVETICA, 12);

            document.add(new Paragraph("FISHCORP - COMPROBANTE DE PAGO", tituloFont));
            document.add(new Paragraph(" "));
            document.add(new LineSeparator());
            document.add(new Paragraph("Fecha: " + Optional.ofNullable(pago.getFechaCreacion()).map(Object::toString).orElse("-"), textoFont));
            document.add(new Paragraph("Referencia: " + Optional.ofNullable(pago.getReferenciaWompi()).orElse("-"), textoFont));
            document.add(new Paragraph("Método de pago: " + Optional.ofNullable(pago.getMetodoPago()).map(Object::toString).orElse("-"), textoFont));
            document.add(new Paragraph("Estado: " + Optional.ofNullable(pago.getEstado()).map(Object::toString).orElse("-"), textoFont));
            String montoStr = "0.00";
            try {
                if (pago.getMonto() != null) montoStr = String.format("%.2f", pago.getMonto());
            } catch (Exception ignored) {
                montoStr = pago.getMonto() == null ? "0.00" : pago.getMonto().toString();
            }
            document.add(new Paragraph("Monto: $" + montoStr, textoFont));

        String cliente = Optional.ofNullable(pago.getPedido())
            .map(Pedido::getCliente)
            .map(c -> Optional.ofNullable(c.getNombre()).orElse("Desconocido"))
            .orElse("Desconocido");

        String pescador = Optional.ofNullable(pago.getPedido())
            .map(Pedido::getProducto)
            .map(Producto::getPescador)
            .map(p -> Optional.ofNullable(p.getNombre()).orElse("Desconocido"))
            .orElse("Desconocido");

            document.add(new Paragraph("Cliente: " + cliente, textoFont));
            document.add(new Paragraph("Pescador: " + pescador, textoFont));
            document.add(new Paragraph(" "));
            document.add(new LineSeparator());
            document.add(new Paragraph("Gracias por confiar en FishCorp 🐟", textoFont));
            document.close();

            return out.toByteArray();
        } catch (Exception e) {
            throw new RuntimeException("Error generando recibo: " + e.getMessage());
        }
    }
}
