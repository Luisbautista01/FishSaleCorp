# 🐟 FishSaleCorp — Guía de API y Flujo del Sistema
<p align="center">
  <img src="https://github.com/Luisbautista01/FishSaleCorp/blob/main/FishSaleCorpApp/assets/logo.png?raw=true" alt="FishSaleCorp Logo" width="180" />
</p>

---

## Menú de secciones 🧭
<p align="center">
 <li> <a href="#🏁-inicio"> 🏁 Inicio</a> </li>
 <li> <a href="#⚙️-antes-de-comenzar"> ⚙️ Antes de comenzar </a> </li> 
 <li> <a href="#📡-rutas-principales-del-sistema"> 📡 Rutas </a> </li>
 <li> <a href="#🔄-cómo-fluye-todo"> 🔄 Flujo</a> </li>
 <li> <a href="#💻-ejemplo-práctico-con-powershell"> 💻 Ejemplo PowerShell </a> </li>
 <li> <a href="#🧠-buenas-prácticas"> 🧠 Buenas prácticas</a> </li>
 <li> <a href="#🧪-pruebas-y-control-de-calidad"> 🧪 Pruebas </a> </li>
 <li> <a href="#archivos-clave-del-proyecto-📂"> 📂 Archivos clave </a> </li>
</p>

---
  
## 🏁 Inicio
> Esta guía fue creada para que todo el equipo de **FishSaleCorp** entienda con claridad cómo fluye nuestra aplicación, desde que un usuario se registra hasta que obtiene su comprobante de pago.

---

## ⚙️ Antes de comenzar 

Cuando levantas el backend, se ejecuta por defecto en `http://localhost:8080`. Cada persona tiene un rol:

- 👤 **Cliente:** compra productos disponibles.  
- 🐟 **Pescador:** publica sus productos para la venta.  
- ⚙️ **Administrador:** supervisa y mantiene todo bajo control.

> 🔐 Algunas rutas requieren iniciar sesión. El token que recibes funciona como llave de acceso.

---

## Rutas principales del sistema 📡

| Ruta | Método | Descripción |
|------|--------|-------------|
| `/api/auth/registro` | POST | Registro de usuario |
| `/api/auth/login` | POST | Inicio de sesión |
| `/api/productos` | GET/POST/PUT/DELETE | Gestión de productos |
| `/api/pedidos` | POST | Crear pedido |
| `/api/pedidos/compuesto` | POST | Crear pedidos compuestos |
| `/api/pagos/simular` | POST | Simular pagos |
| `/api/pagos/{id}/recibo` | GET | Obtener recibo PDF |

> ⚠️ Algunas rutas solo funcionan para ciertos roles o con un token válido.

---

## 🔄 Cómo fluye todo

### 🧾 Registro y acceso
> Todo empieza cuando un usuario se registra con su nombre, correo y contraseña. Después inicia sesión y recibe un token: su pase para explorar la app sin restricciones.

### 🏷 Productos
> Los pescadores y administradores suben productos indicando precio, cantidad y categoría. Los clientes pueden ver la lista, comparar y elegir lo que desean comprar.

### 📦 Pedidos
> El cliente selecciona un producto, indica cantidad y dirección de entrega. El sistema crea un pedido listo para pagar. Los “pedidos compuestos” permiten comprar varios productos al mismo tiempo.

### 💳 Pagos y comprobantes
> Luego viene el pago: el sistema simula una transacción. Si se aprueba, el pedido pasa a “Pagado” y el stock se actualiza. Si se rechaza, no cambia nada. Finalmente, se genera un comprobante en PDF.

---

## 💻 Ejemplo práctico con PowerShell

### 1️⃣ Registro de usuario

```powershell
Invoke-RestMethod -Method Post -Uri "http://localhost:8080/api/auth/registro" -ContentType 'application/json' -Body (@{
    nombre = 'Luis Bautista';
    email = 'luis@example.com';
    password = 'P@ssw0rd';
    rol = 'CLIENTE'
} | ConvertTo-Json)
```

### 2️⃣ Inicio de sesión

``` powershell
$login = @{ email = 'luis@example.com'; password = 'P@ssw0rd' } | ConvertTo-Json
$resp = Invoke-RestMethod -Method Post -Uri "http://localhost:8080/api/auth/login" -ContentType 'application/json' -Body $login
$token = $resp.token
```

### 3️⃣ Crear producto (pescador o admin)

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

### 4️⃣ Crear pedido

```powershell
$pedido = @{
productoId = 101
cantidad = 2
direccion = 'Calle Falsa 123'
} | ConvertTo-Json

Invoke-RestMethod -Method Post -Uri "http://localhost:8080/api/pedidos" -Headers @{ Authorization = "Bearer $token" } -ContentType 'application/json' -Body $pedido
```

### 5️⃣ Simular pago

```powershell
$pago = @{
pedidoId = 555    
metodoPago = 'WOMPI'
monto = 24000
} | ConvertTo-Json

$res = Invoke-RestMethod -Method Post -Uri "http://localhost:8080/api/pagos/simular" -Headers @{ Authorization = "Bearer $token" } -ContentType 'application/json' -Body $pago
$res | Format-List
```

### 6️⃣ Descargar comprobante

```powershell
Invoke-RestMethod -Method Get -Uri "http://localhost:8080/api/pagos/999/recibo" -Headers @{ Authorization = "Bearer $token" } -OutFile "recibo_999.pdf"
```
---

## 🧠 Buenas prácticas

- Valida siempre los datos que ingresan al sistema.
- Usa `BigDecimal` para montos.
- Evita registrar contraseñas o tokens en logs.
- Muestra valores por defecto si algo no viene en la respuesta.

---

## 🧪 Pruebas y control de calidad

- **Pruebas unitarias:** verifican partes individuales del sistema.
- **Pruebas de integración:** comprueban el flujo completo usando base de datos temporal.

---

## 📂 Archivos clave del proyecto

- `AuthController.java` — registro e inicio de sesión.
- `ProductoController.java` — gestión de productos.
- `PedidoController.java` — manejo de pedidos.
- `PagoController.java` — simulación de pagos y comprobantes.

---

<p align="center"> 🐟 <b>FishSaleCorp © 2025</b><br> <i>Documento interno de referencia técnica</i> </p>
