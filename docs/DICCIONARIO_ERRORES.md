# Diccionario de Códigos de Error de GESCO

Este documento detalla la estructura y catálogo de códigos de error estandarizados de **GESCO (Gestión Escolar UPIIZ)**.
Cada código facilita la identificación rápida de fallas para el equipo de desarrollo y soporte técnico, permitiendo que el usuario reporte la incidencia con precisión.

---

## 📐 Estructura de un Código de Error

Los códigos de error en GESCO siguen el formato:

$$\text{ER-XXYY}$$

* **`ER`**: Prefijo de Error de Sistema GESCO.
* **`XX`**: Categoría principal del subsistema afectado.
* **`YY`**: Subtipo o caso específico de la falla.

---

## 🗂️ Categorías Principales

| Rango | Categoría | Descripción |
| :--- | :--- | :--- |
| **`ER-01XX`** | **Interfaz y Renderizado** | Fallas de maquetación, desbordamientos `RenderFlex`, errores en construcción de widgets. |
| **`ER-02XX`** | **Red y Conectividad** | Problemas de red, falta de conexión a Internet, tiempos de espera (*timeout*). |
| **`ER-03XX`** | **Servidor y API (HTTP)** | Respuestas de error del servidor (HTTP 500, 502, 503, 504), fallas de API. |
| **`ER-04XX`** | **Datos y Estado** | Excepciones por valores nulos (*Null Check*), errores al parsear JSON, estado inválido. |
| **`ER-05XX`** | **Archivos y Documentos** | Errores en carga de archivos, lectura/escritura en disco, permisos de almacenamiento. |
| **`ER-09XX`** | **Desconocido / Sistema** | Excepciones no clasificadas o errores inesperados de la plataforma. |

---

## 📚 Catálogo Detallado de Códigos de Error

### `ER-01XX` · Interfaz y Renderizado

| Código | Nombre Técnico | Descripción / Causa | Acción Recomendada |
| :--- | :--- | :--- | :--- |
| **`ER-0101`** | `RenderFlex Overflow` | El contenido de la pantalla superó el espacio disponible (desbordamiento vertical u horizontal). | Recargar pantalla o ajustar tamaño de ventana. Contactar a soporte si persiste. |
| **`ER-0102`** | `Widget Build Error` | Una excepción impidió construir un componente visual de la pantalla. | Recargar la pantalla para reintentar el pintado de la interfaz. |
| **`ER-0103`** | `Navigation State Error` | Se intentó realizar una transición de pantalla inválida o context no montado. | Regresar a la pantalla de inicio ([HomeScreen]). |

### `ER-02XX` · Red y Conectividad

| Código | Nombre Técnico | Descripción / Causa | Acción Recomendada |
| :--- | :--- | :--- | :--- |
| **`ER-0201`** | `Network Unreachable` | Dispositivo sin acceso a Internet o la red escolar no responde. | Verificar la conexión a Wi-Fi o datos móviles y reintentar. |
| **`ER-0202`** | `Connection Timeout` | La solicitud al servidor superó el tiempo límite de respuesta. | Reintentar la operación. Si la red es lenta, esperar unos momentos. |
| **`ER-0203`** | `Socket / SSL Error` | Error en el apretón de manos SSL o canal de comunicación inseguro. | Comprobar que la fecha y hora del dispositivo sean correctas. |

### `ER-03XX` · Servidor y API

| Código | Nombre Técnico | Descripción / Causa | Acción Recomendada |
| :--- | :--- | :--- | :--- |
| **`ER-0301`** | `HTTP 500 Internal Error` | El servidor de GESCO experimentó un error interno al procesar la solicitud. | Copiar el código de error y enviar reporte al departamento de TI. |
| **`ER-0302`** | `HTTP 503 Service Unavailable` | El servidor se encuentra en mantenimiento o saturado. | Esperar unos minutos e intentar nuevamente. |
| **`ER-0303`** | `HTTP 401/403 Unauthorized` | La sesión del usuario expiró o no cuenta con los permisos necesarios. | Iniciar sesión de nuevo en la aplicación. |
| **`ER-0304`** | `HTTP 404 Not Found` | El recurso o trámite solicitado no existe en el servidor. | Verificar la información solicitada en el menú principal. |

### `ER-04XX` · Datos y Estado

| Código | Nombre Técnico | Descripción / Causa | Acción Recomendada |
| :--- | :--- | :--- | :--- |
| **`ER-0401`** | `Null Pointer / Null Check` | Se intentó acceder a un campo obligatorio que venía nulo o no definido. | Copiar código de error y notificar al desarrollador. |
| **`ER-0402`** | `JSON Parse Error` | La respuesta del servidor no coincidió con la estructura esperada por el modelo. | Notificar a desarrollo con el reporte copiado. |
| **`ER-0403`** | `Bad State Error` | El estado interno de un formulario o trámite se encuentra inconsistente. | Reiniciar la aplicación o limpiar caché local. |

### `ER-05XX` · Archivos y Documentos

| Código | Nombre Técnico | Descripción / Causa | Acción Recomendada |
| :--- | :--- | :--- | :--- |
| **`ER-0501`** | `File Read / Write Error` | Fallo al leer o guardar un documento PDF/imagen en el dispositivo. | Verificar que el dispositivo tenga espacio suficiente y permisos de almacenamiento. |
| **`ER-0502`** | `File Size Exceeded` | El archivo adjunto supera el tamaño máximo permitido por GESCO. | Comprimir el archivo o seleccionar un documento con menor tamaño. |

### `ER-09XX` · Excepciones No Manejadas

| Código | Nombre Técnico | Descripción / Causa | Acción Recomendada |
| :--- | :--- | :--- | :--- |
| **`ER-0999`** | `Unhandled System Exception` | Excepción no contemplada en el flujo regular del sistema. | Copiar el informe completo de error con el botón de la app y enviarlo al desarrollador. |

---

## 📋 Formato del Reporte de Error al Copiar

Cuando un usuario presiona el botón **"Copiar código de error"** en la pantalla de prevención de crashes, se genera un reporte en texto plano estructurado de la siguiente forma:

```text
==================================================
        INFORME DE ERROR - GESCO UPIIZ
==================================================
Código de Error : ER-0101
Categoría       : Interfaz y Renderizado (RenderFlex Overflow)
Fecha y Hora    : 2026-03-31 15:45:12
Plataforma      : Android / Web / Windows
--------------------------------------------------
MENSAJE DE ERROR:
A RenderFlex overflowed by 42 pixels on the bottom.

DETALLE TÉCNICO Y TRAZA:
#0      Container.build (package:flutter/src/widgets/container.dart:240)
#1      _ExpedienteScreenState.build (package:gesco/features/expediente/expediente_screen.dart:102)
...
==================================================
Favor de enviar este informe al área de desarrollo de GESCO.
