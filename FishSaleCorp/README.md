<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>FishSaleCorp - Guía de Flujo</title>
<style>
  @import url('https://fonts.googleapis.com/css2?family=Poppins:wght@400;600&display=swap');
  @page {
    margin: 2.5cm 2cm 3cm 2cm;
  }
  @media print {
    header { position: fixed; top: 0; left: 0; right: 0; }
    footer { position: fixed; bottom: 0; left: 0; right: 0; }
    section { page-break-after: auto; }
  }
  body {
    font-family: 'Poppins', sans-serif;
    background: #f8fafc;
    margin: 0;
    color: #2c3e50;
    line-height: 1.7;
    font-size: 15px;
  }
  header {
    display: flex;
    align-items: center;
    gap: 16px;
    background: linear-gradient(90deg, #0277bd, #039be5);
    color: white;
    padding: 20px 36px;
    box-shadow: 0 2px 6px rgba(0,0,0,0.2);
  }
  header img {
    width: 58px;
    border-radius: 10px;
  }
  header h1 {
    font-size: 1.9em;
    font-weight: 600;
    letter-spacing: 0.4px;
  }
  section {
    padding: 32px;
    max-width: 1100px;
    margin: 0 auto;
  }
  h2, h3 {
    color: #0277bd;
    margin-top: 36px;
  }
  section {
    padding: 40px 36px 60px;
    max-width: 1100px;
    margin: 0 auto;
  }
  h2 {
    color: #0277bd;
    margin-top: 48px;
    margin-bottom: 12px;
    font-size: 1.4em;
  }
  h3 {
    color: #01579b;
    margin-top: 28px;
    font-size: 1.15em;
  }
  p { margin-bottom: 16px; }
  .card {
    background: white;
    border-radius: 14px;
    padding: 20px 22px;
    margin-bottom: 20px;
    box-shadow: 0 4px 12px rgba(0,0,0,0.08);
    transition: transform 0.2s, box-shadow 0.2s;
  }
  .card:hover {
    transform: translateY(-2px);
    box-shadow: 0 6px 16px rgba(0,0,0,0.12);
  }
  .endpoint-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit,minmax(260px,1fr));
    gap: 18px;
  }
  blockquote {
    border-left: 4px solid #0288d1;
    padding: 10px 14px;
    margin: 22px 0;
    background: #e3f2fd;
    border-radius: 8px;
    color: #444;
    font-style: italic;
  }
  pre {
    background: #f4f6f8;
    padding: 14px;
    border-radius: 8px;
    overflow-x: auto;
    font-size: 0.9em;
  }
  code {
    font-family: 'Courier New', Courier, monospace;
    color: #0277bd;
  }
  ul {
    margin: 0;
    padding-left: 22px;
  }
  li {
    margin-bottom: 8px;
  }
  .emoji {
    font-size: 1.3em;
    margin-right: 6px;
  }
</style>
</head>
<body>

<header>
  <img src="https://raw.githubusercontent.com/Luisbautista01/FishSaleCorp/main/logo.png" alt="FishSaleCorp Logo">
  <h1>🐟 FishSaleCorp — Guía de API y Flujo del Sistema</h1>
</header>

<section>
  <p>Esta guía fue creada para que todo el equipo de <strong>FishSaleCorp</strong> entienda con claridad cómo fluye nuestra aplicación, desde que un usuario se registra hasta que obtiene su comprobante de pago. Aquí no hay jerga técnica: solo una explicación directa y práctica del recorrido completo.</p>

  <h2>🚀 Antes de comenzar</h2>
  <div class="card">
    <p>Cuando levantas el backend, se ejecuta por defecto en <code>http://localhost:8080</code>. Cada persona que use la app tiene un rol que define qué puede hacer:</p>
    <ul>
      <li>👤 <strong>Cliente:</strong> compra productos disponibles.</li>
      <li>🐟 <strong>Pescador:</strong> publica sus productos para la venta.</li>
      <li>⚙️ <strong>Administrador:</strong> supervisa y mantiene todo bajo control.</li>
    </ul>
    <p>Algunas rutas requieren iniciar sesión. Cuando lo haces, el sistema te entrega un token que es como una llave para acceder a tus funciones.</p>
  </div>

  <h2>📦 Rutas principales del sistema</h2>
  <div class="endpoint-grid">
    <div class="card"><span class="emoji">🧾</span><strong>Registro</strong><br>POST /api/auth/registro</div>
    <div class="card"><span class="emoji">🔐</span><strong>Login</strong><br>POST /api/auth/login</div>
    <div class="card"><span class="emoji">🎣</span><strong>Productos</strong><br>GET/POST/PUT/DELETE /api/productos</div>
    <div class="card"><span class="emoji">🛍️</span><strong>Pedidos</strong><br>POST /api/pedidos</div>
    <div class="card"><span class="emoji">📦</span><strong>Pedidos compuestos</strong><br>POST /api/pedidos/compuesto</div>
    <div class="card"><span class="emoji">💳</span><strong>Pagos</strong><br>POST /api/pagos/simular</div>
    <div class="card"><span class="emoji">📄</span><strong>Recibo PDF</strong><br>GET /api/pagos/{id}/recibo</div>
  </div>
  <blockquote>👉 Algunas rutas solo funcionan para ciertos roles o con un token válido.</blockquote>

  <h2>✨ Cómo fluye todo</h2>

  <h3>🧾 Registro y acceso</h3>
  <div class="card">
    <p>Todo empieza cuando un usuario se registra con su nombre, correo y contraseña. Después inicia sesión y el sistema le da un token: su pase para explorar la app sin restricciones.</p>
  </div>

  <h3>🎣 Productos</h3>
  <div class="card">
    <p>Los pescadores y administradores suben productos (por ejemplo, “Salmón fresco”) indicando su precio, cantidad y categoría. Los clientes pueden ver la lista, comparar y elegir lo que desean comprar.</p>
  </div>

  <h3>🛍️ Pedidos</h3>
  <div class="card">
    <p>El cliente selecciona un producto, indica cuántas unidades quiere y dónde recibirlo. El sistema crea un pedido que queda listo para pagar. También existen los “pedidos compuestos” para comprar varios productos al tiempo.</p>
  </div>

  <h3>💳 Pagos y comprobantes</h3>
  <div class="card">
    <p>Luego viene el pago: el sistema simula una transacción (por ejemplo, usando WOMPI). Si el pago se aprueba, el pedido pasa a “Pagado” y el stock se actualiza. Si se rechaza, no cambia nada. Finalmente, se genera un comprobante en PDF para descargar o archivar.</p>
  </div>

  <h2>🧭 Ejemplo práctico con PowerShell</h2>
  <p>Para quienes deseen probar el flujo completo desde consola, estos son los pasos con ejemplos reales:</p>

  <h3>1️⃣ Registro de usuario</h3>
  <div class="card">
    <pre><code>Invoke-RestMethod -Method Post -Uri "http://localhost:8080/api/auth/registro" -ContentType 'application/json' -Body (@{
    nombre = 'Luis Bautista';
    email = 'luis@example.com';
    password = 'P@ssw0rd';
    rol = 'CLIENTE'
} | ConvertTo-Json)</code></pre>
  </div>

  <h3>2️⃣ Inicio de sesión</h3>
  <div class="card">
    <pre><code>$login = @{ email = 'luis@example.com'; password = 'P@ssw0rd' } | ConvertTo-Json
$resp = Invoke-RestMethod -Method Post -Uri "http://localhost:8080/api/auth/login" -ContentType 'application/json' -Body $login
$token = $resp.token</code></pre>
  </div>

  <h3>3️⃣ Crear producto (pescador o admin)</h3>
  <div class="card">
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
  <div class="card">
    <pre><code>$pedido = @{
  productoId = 101
  cantidad = 2
  direccion = 'Calle Falsa 123'
} | ConvertTo-Json

Invoke-RestMethod -Method Post -Uri "http://localhost:8080/api/pedidos" -Headers @{ Authorization = "Bearer $token" } -ContentType 'application/json' -Body $pedido</code></pre>
  </div>

  <h3>5️⃣ Simular pago</h3>
  <div class="card">
    <pre><code>$pago = @{
  pedidoId = 555    
  metodoPago = 'WOMPI'
  monto = 24000
} | ConvertTo-Json

$res = Invoke-RestMethod -Method Post -Uri "http://localhost:8080/api/pagos/simular" -Headers @{ Authorization = "Bearer $token" } -ContentType 'application/json' -Body $pago
$res | Format-List</code></pre>
  </div>

  <h3>6️⃣ Descargar comprobante</h3>
  <div class="card">
    <pre><code>Invoke-RestMethod -Method Get -Uri "http://localhost:8080/api/pagos/999/recibo" -Headers @{ Authorization = "Bearer $token" } -OutFile "recibo_999.pdf"</code></pre>
  </div>

  <h2>✅ Buenas prácticas</h2>
  <div class="card">
    <ul>
      <li>Valida siempre los datos que ingresan al sistema (nada de campos vacíos).</li>
      <li>Usa <code>BigDecimal</code> para montos, es más preciso para dinero.</li>
      <li>Evita registrar contraseñas o tokens en los logs.</li>
      <li>Si algo no viene en la respuesta, muestra valores por defecto en su lugar.</li>
    </ul>
  </div>

  <h2>🧪 Pruebas y control de calidad</h2>
  <div class="card">
    <ul>
      <li><strong>Pruebas unitarias:</strong> aseguran que cada parte del sistema funcione de forma independiente.</li>
      <li><strong>Pruebas de integración:</strong> usan una base de datos temporal (H2) para comprobar todo el flujo, desde el registro hasta el pago.</li>
    </ul>
  </div>

  <h2>🗂️ Archivos clave del proyecto</h2>
  <div class="card">
    <ul>
      <li><code>AuthController.java</code> — registro e inicio de sesión.</li>
      <li><code>ProductoController.java</code> — gestión de productos.</li>
      <li><code>PedidoController.java</code> — manejo de pedidos.</li>
      <li><code>PagoController.java</code> — simulación de pagos y comprobantes.</li>
    </ul>
  </div>

  <div style="margin-top:40px; text-align:center; font-weight:600;">
    FishSaleCorp © 2025 — Documento interno de referencia técnica
  </div>
</section>
</body>
</html>
