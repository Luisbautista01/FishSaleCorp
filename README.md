<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>FishSaleCorp - Guía de Flujo</title>
<!-- Bootstrap 5 CSS -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
<!-- Google Fonts -->
<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;600&display=swap" rel="stylesheet">
<style>
  html {
    scroll-behavior: smooth;
  }
  body {
    font-family: 'Poppins', sans-serif;
    background-color: #f8fafc;
    color: #2c3e50;
  }
  header {
    background: linear-gradient(90deg, #0277bd, #039be5);
    color: white;
    z-index: 1030;
  }
  header img {
    width: 50px;
    border-radius: 10px;
  }
  h2, h3 {
    color: #0277bd;
  }
  h3 {
    color: #01579b;
  }
  .card {
    border-radius: 14px;
    box-shadow: 0 4px 12px rgba(0,0,0,0.08);
  }
  pre {
    background: #f4f6f8;
    padding: 12px;
    border-radius: 8px;
    overflow-x: auto;
    font-size: 0.9em;
  }
  code {
    font-family: 'Courier New', Courier, monospace;
    color: #0277bd;
  }
  .sidebar-desktop {
    height: 100vh;
    position: fixed;
    top: 70px;
    left: 0;
    padding-top: 20px;
    width: 220px;
    background-color: #f8f9fa;
    border-right: 1px solid #ddd;
    overflow-y: auto;
  }
  .sidebar-desktop a {
    display: block;
    padding: 10px 15px;
    color: #0277bd;
    text-decoration: none;
    font-weight: 500;
  }
  .sidebar-desktop a:hover {
    background-color: #e3f2fd;
    border-radius: 8px;
  }
  .content {
    margin-left: 240px;
    padding: 20px;
  }
  @media (max-width: 768px) {
    .sidebar-desktop {
      display: none;
    }
    .content {
      margin-left: 0;
    }
  }
</style>
</head>
<body>

<!-- Header -->
<header class="d-flex align-items-center p-3 shadow-sm fixed-top">
  <img src="assets/logo.png" alt="FishSaleCorp Logo">
  <h1 class="ms-3 fs-5 fw-bold flex-grow-1">🐟 FishSaleCorp — Guía de API y Flujo del Sistema</h1>

  <!-- Botón menú offcanvas para móviles -->
  <button class="btn btn-light d-md-none" type="button" data-bs-toggle="offcanvas" data-bs-target="#mobileSidebar" aria-controls="mobileSidebar">
    ☰ Menú
  </button>
</header>

<!-- Sidebar fijo escritorio -->
<div class="sidebar-desktop">
  <a href="#inicio">Inicio</a>
  <a href="#antes">Antes de comenzar</a>
  <a href="#rutas">Rutas principales</a>
  <a href="#flujo">Flujo del sistema</a>
  <a href="#ejemplos">Ejemplo PowerShell</a>
  <a href="#buenas">Buenas prácticas</a>
  <a href="#pruebas">Pruebas y control</a>
  <a href="#archivos">Archivos clave</a>
</div>

<!-- Offcanvas para móviles -->
<div class="offcanvas offcanvas-start" tabindex="-1" id="mobileSidebar" aria-labelledby="mobileSidebarLabel">
  <div class="offcanvas-header">
    <h5 class="offcanvas-title" id="mobileSidebarLabel">Menú</h5>
    <button type="button" class="btn-close" data-bs-dismiss="offcanvas" aria-label="Cerrar"></button>
  </div>
  <div class="offcanvas-body">
    <a href="#inicio" data-bs-dismiss="offcanvas">Inicio</a>
    <a href="#antes" data-bs-dismiss="offcanvas">Antes de comenzar</a>
    <a href="#rutas" data-bs-dismiss="offcanvas">Rutas principales</a>
    <a href="#flujo" data-bs-dismiss="offcanvas">Flujo del sistema</a>
    <a href="#ejemplos" data-bs-dismiss="offcanvas">Ejemplo PowerShell</a>
    <a href="#buenas" data-bs-dismiss="offcanvas">Buenas prácticas</a>
    <a href="#pruebas" data-bs-dismiss="offcanvas">Pruebas y control</a>
    <a href="#archivos" data-bs-dismiss="offcanvas">Archivos clave</a>
  </div>
</div>

<!-- Content -->
<div class="content">

  <!-- Inicio -->
  <section id="inicio">
    <p>Esta guía fue creada para que todo el equipo de <strong>FishSaleCorp</strong> entienda con claridad cómo fluye nuestra aplicación, desde que un usuario se registra hasta que obtiene su comprobante de pago.</p>
  </section>

  <!-- Antes de comenzar -->
  <section id="antes">
    <h2>🚀 Antes de comenzar</h2>
    <div class="card p-3 mb-3">
      <p>Cuando levantas el backend, se ejecuta por defecto en <code>http://localhost:8080</code>. Cada persona tiene un rol:</p>
      <ul>
        <li>👤 <strong>Cliente:</strong> compra productos disponibles.</li>
        <li>🐟 <strong>Pescador:</strong> publica sus productos para la venta.</li>
        <li>⚙️ <strong>Administrador:</strong> supervisa y mantiene todo bajo control.</li>
      </ul>
      <p>Algunas rutas requieren iniciar sesión. El token que recibes funciona como llave de acceso.</p>
    </div>
  </section>

  <!-- Rutas principales -->
  <section id="rutas">
    <h2>📦 Rutas principales del sistema</h2>
    <div class="row row-cols-1 row-cols-md-2 row-cols-lg-3 g-3 mb-3">
      <div class="col"><div class="card p-3">🧾 <strong>Registro</strong><br>POST /api/auth/registro</div></div>
      <div class="col"><div class="card p-3">🔐 <strong>Login</strong><br>POST /api/auth/login</div></div>
      <div class="col"><div class="card p-3">🎣 <strong>Productos</strong><br>GET/POST/PUT/DELETE /api/productos</div></div>
      <div class="col"><div class="card p-3">🛍️ <strong>Pedidos</strong><br>POST /api/pedidos</div></div>
      <div class="col"><div class="card p-3">📦 <strong>Pedidos compuestos</strong><br>POST /api/pedidos/compuesto</div></div>
      <div class="col"><div class="card p-3">💳 <strong>Pagos</strong><br>POST /api/pagos/simular</div></div>
      <div class="col"><div class="card p-3">📄 <strong>Recibo PDF</strong><br>GET /api/pagos/{id}/recibo</div></div>
    </div>
    <blockquote class="border-start border-4 border-primary ps-3 fst-italic">👉 Algunas rutas solo funcionan para ciertos roles o con un token válido.</blockquote>
  </section>

  <!-- Flujo del sistema -->
  <section id="flujo">
    <h2>✨ Cómo fluye todo</h2>
    <h3>🧾 Registro y acceso</h3>
    <div class="card p-3 mb-3">
      <p>Todo empieza cuando un usuario se registra con su nombre, correo y contraseña. Después inicia sesión y recibe un token: su pase para explorar la app sin restricciones.</p>
    </div>
    <h3>🏷 Productos</h3>
    <div class="card p-3 mb-3">
      <p>Los pescadores y administradores suben productos indicando precio, cantidad y categoría. Los clientes pueden ver la lista, comparar y elegir lo que desean comprar.</p>
    </div>
    <h3>📦 Pedidos</h3>
    <div class="card p-3 mb-3">
      <p>El cliente selecciona un producto, indica cantidad y dirección de entrega. El sistema crea un pedido listo para pagar. Los “pedidos compuestos” permiten comprar varios productos al mismo tiempo.</p>
    </div>
    <h3>💳 Pagos y comprobantes</h3>
    <div class="card p-3 mb-3">
      <p>Luego viene el pago: el sistema simula una transacción. Si se aprueba, el pedido pasa a “Pagado” y el stock se actualiza. Si se rechaza, no cambia nada. Finalmente, se genera un comprobante en PDF.</p>
    </div>
  </section>

  <!-- Ejemplo PowerShell -->
  <section id="ejemplos">
    <h2>🧭 Ejemplo práctico con PowerShell</h2>
    <p>Pasos con ejemplos reales:</p>

    <h3>1️⃣ Registro de usuario</h3>
    <div class="card p-3 mb-3">
      <pre><code>Invoke-RestMethod -Method Post -Uri "http://localhost:8080/api/auth/registro" -ContentType 'application/json' -Body (@{
nombre = 'Luis Bautista';
email = 'luis@example.com';
password = 'P@ssw0rd';
rol = 'CLIENTE'
} | ConvertTo-Json)</code></pre>
    </div>

    <h3>2️⃣ Inicio de sesión</h3>
    <div class="card p-3 mb-3">
      <pre><code>$login = @{ email = 'luis@example.com'; password = 'P@ssw0rd' } | ConvertTo-Json
$resp = Invoke-RestMethod -Method Post -Uri "http://localhost:8080/api/auth/login" -ContentType 'application/json' -Body $login
$token = $resp.token</code></pre>
    </div>

    <h3>3️⃣ Crear producto (pescador o admin)</h3>
    <div class="card p-3 mb-3">
      <pre><code>$body = @{
nombre = 'Salmón fresco'
precio = 12000
cantidad = 50
categoria = 'Pescados'
pescadorId = 42
} | ConvertTo-Json

Invoke-RestMethod -Method Post -Uri "http://localhost:8080/api/productos" -Headers @{ Authorization = "Bearer $token" } -ContentType 'application/json' -Body $body</code></pre>
    </div>

    <h3>4️⃣ Crear pedido</h3>
    <div class="card p-3 mb-3">
      <pre><code>$pedido = @{
productoId = 101
cantidad = 2
direccion = 'Calle Falsa 123'
} | ConvertTo-Json

Invoke-RestMethod -Method Post -Uri "http://localhost:8080/api/pedidos" -Headers @{ Authorization = "Bearer $token" } -ContentType 'application/json' -Body $pedido</code></pre>
    </div>

    <h3>5️⃣ Simular pago</h3>
    <div class="card p-3 mb-3">
      <pre><code>$pago = @{
pedidoId = 555    
metodoPago = 'WOMPI'
monto = 24000
} | ConvertTo-Json

$res = Invoke-RestMethod -Method Post -Uri "http://localhost:8080/api/pagos/simular" -Headers @{ Authorization = "Bearer $token" } -ContentType 'application/json' -Body $pago
$res | Format-List</code></pre>
    </div>

    <h3>6️⃣ Descargar comprobante</h3>
    <div class="card p-3 mb-3">
      <pre><code>Invoke-RestMethod -Method Get -Uri "http://localhost:8080/api/pagos/999/recibo" -Headers @{ Authorization = "Bearer $token" } -OutFile "recibo_999.pdf"</code></pre>
    </div>
  </section>

  <!-- Buenas prácticas -->
  <section id="buenas">
    <h2>✅ Buenas prácticas</h2>
    <div class="card p-3 mb-3">
      <ul>
        <li>Valida siempre los datos que ingresan al sistema.</li>
        <li>Usa <code>BigDecimal</code> para montos.</li>
        <li>Evita registrar contraseñas o tokens en logs.</li>
        <li>Muestra valores por defecto si algo no viene en la respuesta.</li>
      </ul>
    </div>
  </section>

  <!-- Pruebas -->
  <section id="pruebas">
    <h2>🧪 Pruebas y control de calidad</h2>
    <div class="card p-3 mb-3">
      <ul>
        <li><strong>Pruebas unitarias:</strong> verifican partes individuales del sistema.</li>
        <li><strong>Pruebas de integración:</strong> comprueban el flujo completo usando base de datos temporal.</li>
      </ul>
    </div>
  </section>

  <!-- Archivos clave -->
  <section id="archivos">
    <h2>🗂️ Archivos clave del proyecto</h2>
    <div class="card p-3 mb-5">
      <ul>
        <li><code>AuthController.java</code> — registro e inicio de sesión.</li>
        <li><code>ProductoController.java</code> — gestión de productos.</li>
        <li><code>PedidoController.java</code> — manejo de pedidos.</li>
        <li><code>PagoController.java</code> — simulación de pagos y comprobantes.</li>
      </ul>
    </div>
    <div class="text-center fw-semibold mb-5">
      FishSaleCorp © 2025 — Documento interno de referencia técnica
    </div>
  </section>

</div>

<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
