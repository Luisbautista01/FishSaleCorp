<!-- prettier-ignore -->
# 🐟 FishSaleCorp — Flujo: registro → pedido → pago → comprobante

Una guía compacta y práctica para desarrolladores: describe el proceso desde el registro de un usuario hasta la descarga del comprobante de pago (PDF). Está escrita para usar con la API del proyecto y contiene ejemplos listos para PowerShell. Si prefieres, puedo añadir ejemplos con curl o un script de integración.

---

## 🚀 Quick start

- Puerto por defecto: `http://localhost:8080`
- Formato de autenticación: Bearer token (si tu servicio retorna JWT en el login)
- Roles principales: `CLIENTE`, `PESCADOR`, `ADMIN`

Tip rápido: abre una terminal PowerShell para ejecutar los ejemplos tal como están.

---

## 📦 Endpoints

| Acción | Método | Ruta |
|---|---:|---|
| Registro | POST | `/api/auth/registro` |
| Login | POST | `/api/auth/login` |
| Crear/listar productos | GET/POST/PUT/DELETE | `/api/productos` |
| Crear pedido | POST | `/api/pedidos` |
| Pedido compuesto | POST | `/api/pedidos/compuesto` |
| Simular pago | POST | `/api/pagos/simular` |
| Descargar recibo | GET | `/api/pagos/{id}/recibo` |

> Nota: las rutas reales se obtuvieron de los controladores del proyecto. Algunas requieren encabezado `Authorization` y roles específicos.

---

## ✨ Endpoints destacados

### 🧾 Registro / Autenticación

POST /api/auth/registro — crea usuario

POST /api/auth/login — inicio de sesión (posible token en `UsuarioResponse.token`)

### 🛒 Productos

POST /api/productos — crear producto (roles: `ADMIN` o `PESCADOR`)

GET /api/productos — listar (roles: `CLIENTE`, `PESCADOR`, `ADMIN`)

### 📝 Pedidos

POST /api/pedidos — crear pedido (ROLE: CLIENTE)

POST /api/pedidos/compuesto — crear pedidos compuestos (ROLE: CLIENTE)

### 💳 Pagos

POST /api/pagos/simular — simula un pago; si queda APROBADO actualiza stock y estado del pedido

GET /api/pagos/{id}/recibo — descarga recibo en PDF

---

## 🛠️ Ejemplos

1) Registro

```powershell
Invoke-RestMethod -Method Post -Uri "http://localhost:8080/api/auth/registro" -ContentType 'application/json' -Body (@{
    nombre = 'Luis Bautista';
    email = 'luis@example.com';
    password = 'P@ssw0rd';
    rol = 'CLIENTE'
} | ConvertTo-Json)
```

2) Login (guardar token si viene)

```powershell
$login = @{ email = 'luis@example.com'; password = 'P@ssw0rd' } | ConvertTo-Json
$resp = Invoke-RestMethod -Method Post -Uri "http://localhost:8080/api/auth/login" -ContentType 'application/json' -Body $login
$token = $resp.token
```

3) Crear producto (ejemplo — rol ADMIN/PESCADOR)

```powershell
$body = @{
  nombre = 'Salmón fresco'
  precio = 12000
  cantidad = 50
  categoria = 'Pescados'
  pescadorId = 42
} | ConvertTo-Json

Invoke-RestMethod -Method Post -Uri "http://localhost:8080/api/productos" -Headers @{ Authorization = "Bearer $token" } -ContentType 'application/json' -Body $body
```

4) Crear pedido (CLIENTE)

```powershell
$pedido = @{
  productoId = 101
  cantidad = 2
  direccion = 'Calle Falsa 123'
} | ConvertTo-Json

Invoke-RestMethod -Method Post -Uri "http://localhost:8080/api/pedidos" -Headers @{ Authorization = "Bearer $token" } -ContentType 'application/json' -Body $pedido
```

5) Simular pago

```powershell
$pago = @{
  pedidoId = 555    
  metodoPago = 'WOMPI'
  monto = 24000
} | ConvertTo-Json

$res = Invoke-RestMethod -Method Post -Uri "http://localhost:8080/api/pagos/simular" -Headers @{ Authorization = "Bearer $token" } -ContentType 'application/json' -Body $pago
$res | Format-List
```

6) Descargar comprobante (PDF)

```powershell
Invoke-RestMethod -Method Get -Uri "http://localhost:8080/api/pagos/999/recibo" -Headers @{ Authorization = "Bearer $token" } -OutFile "recibo_999.pdf"
```

---

## ✅ Buenas prácticas y recomendaciones

- Valida siempre los DTOs con `@Valid` y utiliza anotaciones de Jakarta (`@NotNull`, `@NotBlank`, `@Positive`).
- Mantén `BigDecimal` para valores monetarios y evita usar `double` para cálculos financieros.
- Registra eventos relevantes (creación de pedido, cambio de estado, pago aprobado/rechazado) pero evita loggear tokens o contraseñas.
- Para campos opcionales en PDFs y respuestas, utiliza valores por defecto (`"Desconocido"`, `"-"`) para evitar NPE y mejorar UX.

---

## 🧪 Pruebas y sugerencias de integración

- Pruebas unitarias: mockear `PagoRepository`, `PedidoRepository` y `ProductoRepository` para probar `PagoService.simularPago` (APROBADO / RECHAZADO).
- Pruebas de integración: usar H2 en memoria y ejecutar el flujo end-to-end para validar stock y estados.

---

## 🗂️ Archivos útiles

- `src/main/java/com/example/FishCorp/Controller/AuthController.java`
- `src/main/java/com/example/FishCorp/Controller/ProductoController.java`
- `src/main/java/com/example/FishCorp/Controller/PedidoController.java`
- `src/main/java/com/example/FishCorp/Controller/PagoController.java`

Si quieres, puedo: añadir ejemplos con `curl`, incluir tarjetas de DTOs (ejemplos JSON exactos para `PedidoCompuestoRequest` y `PagoRequest`) o generar un script PowerShell que ejecute el flujo completo en H2.

---

_Última actualización: mejora visual y organización para presentación profesional_

Resumen del flujo (rutas reales)

- Registro: POST /api/auth/registro
- Login:    POST /api/auth/login
- Productos: GET/POST/PUT/DELETE bajo /api/productos
- Pedidos:  POST /api/pedidos (y POST /api/pedidos/compuesto para pedidos compuestos)
- Pago (simulado): POST /api/pagos/simular
- Recibo (PDF): GET /api/pagos/{id}/recibo

Notas generales

- Varias rutas están protegidas por roles (ver anotaciones @PreAuthorize):
  - Crear producto: ADMIN o PESCADOR
  - Crear pedido: CLIENTE
  - Simular pago: CLIENTE
  - Listados de pagos: ADMIN, PESCADOR, CLIENTE según el endpoint
- El servidor corre por defecto en http://localhost:8080 en el entorno de desarrollo.

Ejemplos paso a paso usando PowerShell

1) Registro de usuario

Request (POST /api/auth/registro)

```powershell
Invoke-RestMethod -Method Post -Uri "http://localhost:8080/api/auth/registro" -ContentType 'application/json' -Body (@{
    nombre = 'Luis Bautista';
    email = 'luis@example.com';
    password = 'P@ssw0rd';
    rol = 'CLIENTE'
} | ConvertTo-Json)
```

Response esperado: 201 Created con un objeto `UsuarioResponse` (id, nombre, email, rol). En la respuesta de login puede venir, además, un token.

2) Login (obtener token)

Request (POST /api/auth/login)

```powershell
$login = @{ email = 'luis@example.com'; password = 'P@ssw0rd' } | ConvertTo-Json
$resp = Invoke-RestMethod -Method Post -Uri "http://localhost:8080/api/auth/login" -ContentType 'application/json' -Body $login
$resp | Format-List
```

La respuesta viene en la forma `UsuarioResponse` que puede incluir un campo `token` (si el servicio entrega JWT). Si obtienes token, usa Authorization: Bearer <token> para llamadas autenticadas.

3) Crear un producto (solo ADMIN o PESCADOR)

Request (POST /api/productos)

```powershell
$body = @{
  nombre = 'Salmón fresco'
  precio = 12000
  cantidad = 50
  categoria = 'Pescados'
  pescadorId = 42
} | ConvertTo-Json

Invoke-RestMethod -Method Post -Uri "http://localhost:8080/api/productos" -Headers @{ Authorization = "Bearer $token" } -ContentType 'application/json' -Body $body
```

Response esperado: 201 Created con el producto creado.

4) Crear pedido (CLIENTE)

Request (POST /api/pedidos)

```powershell
$pedido = @{
  productoId = 101
  cantidad = 2
  direccion = 'Calle Falsa 123'
} | ConvertTo-Json

Invoke-RestMethod -Method Post -Uri "http://localhost:8080/api/pedidos" -Headers @{ Authorization = "Bearer $token" } -ContentType 'application/json' -Body $pedido
```

Response esperado: objeto `PedidoResponse` con el id del pedido y su estado (inicialmente PENDIENTE u otro definido en el servicio).

5) Simular pago (POST /api/pagos/simular)

El endpoint real es `/api/pagos/simular`. El servicio hará validaciones y retornará un `PagoResponse`.

Request (ejemplo)

```powershell
$pago = @{
  pedidoId = 555   
  metodoPago = 'WOMPI'
  monto = 24000
} | ConvertTo-Json

$res = Invoke-RestMethod -Method Post -Uri "http://localhost:8080/api/pagos/simular" -Headers @{ Authorization = "Bearer $token" } -ContentType 'application/json' -Body $pago
$res | Format-List
```

Respuesta típica (PagoResponse): contiene id, referencia, estado (APROBADO/RECHAZADO), monto y fecha.

Si el pago queda APROBADO, `PagoService` actualiza stock y el estado del pedido (ENVIADO). Si queda RECHAZADO, deja el pedido sin cambios.

6) Descargar comprobante (GET /api/pagos/{id}/recibo)

Request (GET)

```powershell
# Guarda el PDF localmente
Invoke-RestMethod -Method Get -Uri "http://localhost:8080/api/pagos/999/recibo" -Headers @{ Authorization = "Bearer $token" } -OutFile "recibo_999.pdf"
```

El endpoint devuelve `application/pdf` y fuerza descarga con header Content-Disposition.

Notas de validación y seguridad

- Usa `@Valid` y anotaciones de Jakarta Validation en los DTOs. Los controladores ya esperan `@Valid` en algunos endpoints (p.ej. registro y creación de pedidos compuestos).
- No expongas tokens en logs de producción.
- Mantén BigDecimal para valores monetarios y evita conversiones imprecisas.

Errores comunes y cómo detectarlos

- 401/403: revisar roles y encabezado Authorization.
- 400: datos de entrada inválidos (falta `pescadorId` al crear producto, etc.).
- 404: recurso no encontrado (producto, pedido, usuario).

Qué puedo hacer a continuación

- Reescribir ejemplos para `curl` si los necesitas.
- Generar un pequeño script de integración que haga el flujo completo en H2 (tests de integración).
- Añadir ejemplos más detallados de `PedidoCompuestoRequest` si quieres usar la ruta `/api/pedidos/compuesto`.

Archivos relevantes

- `src/main/java/com/example/FishCorp/Controller/AuthController.java`
- `src/main/java/com/example/FishCorp/Controller/ProductoController.java`
- `src/main/java/com/example/FishCorp/Controller/PedidoController.java`
- `src/main/java/com/example/FishCorp/Controller/PagoController.java`

