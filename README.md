# 🐟 FishSaleCorp — Guía de API y Flujo del Sistema

![Logo](assets/logo.png)

---

## 📌 Índice

- [Inicio](#inicio)
- [Antes de comenzar](#antes-de-comenzar)
- [Rutas principales del sistema](#rutas-principales-del-sistema)
- [Cómo fluye todo](#cómo-fluye-todo)
- [Ejemplo práctico con PowerShell](#ejemplo-práctico-con-powershell)
- [Buenas prácticas](#buenas-prácticas)
- [Pruebas y control de calidad](#pruebas-y-control-de-calidad)
- [Archivos clave del proyecto](#archivos-clave-del-proyecto)

---

## Inicio

Esta guía fue creada para que todo el equipo de **FishSaleCorp** entienda con claridad cómo fluye nuestra aplicación, desde que un usuario se registra hasta que obtiene su comprobante de pago.

---

## Antes de comenzar

Cuando levantas el backend, se ejecuta por defecto en `http://localhost:8080`. Cada persona tiene un rol:

- 👤 **Cliente:** compra productos disponibles.
- 🐟 **Pescador:** publica sus productos para la venta.
- ⚙️ **Administrador:** supervisa y mantiene todo bajo control.

Algunas rutas requieren iniciar sesión. El token que recibes funciona como llave de acceso.

---

## Rutas principales del sistema

| Función | Método / Ruta |
|---------|---------------|
| 🧾 **Registro** | POST `/api/auth/registro` |
| 🔐 **Login** | POST `/api/auth/login` |
| 🎣 **Productos** | GET/POST/PUT/DELETE `/api/productos` |
| 🛍️ **Pedidos** | POST `/api/pedidos` |
| 📦 **Pedidos compuestos** | POST `/api/pedidos/compuesto` |
| 💳 **Pagos** | POST `/api/pagos/simular` |
| 📄 **Recibo PDF** | GET `/api/pagos/{id}/recibo` |

> ⚠️ Algunas rutas solo funcionan para ciertos roles o con un token válido.

---

## Cómo fluye todo

### 🧾 Registro y acceso
Todo empieza cuando un usuario se registra con su nombre, correo y contraseña. Después inicia sesión y recibe un token: su pase para explorar la app sin restricciones.

### 🎣 Productos
Los pescadores y administradores suben productos indicando precio, cantidad y categoría. Los clientes pueden ver la lista, comparar y elegir lo que desean comprar.

### 🛍️ Pedidos
El cliente selecciona un producto, indica cantidad y dirección de entrega. El sistema crea un pedido listo para pagar. Los “pedidos compuestos” permiten comprar varios productos al mismo tiempo.

### 💳 Pagos y comprobantes
Luego viene el pago: el sistema simula una transacción. Si se aprueba, el pedido pasa a “Pagado” y el stock se actualiza. Si se rechaza, no cambia nada. Finalmente, se genera un comprobante en PDF.

---

## Ejemplo práctico con PowerShell

### 1️⃣ Registro de usuario
```powershell
Invoke-RestMethod -Method Post -Uri "http://localhost:8080/api/auth/registro" -ContentType 'application/json' -Body (@{
    nombre = 'Luis Bautista';
    email = 'luis@example.com';
    password = 'P@ssw0rd';
    rol = 'CLIENTE'
} | ConvertTo-Json)
