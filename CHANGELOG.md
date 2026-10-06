# Historial de Cambios (Changelog) - GESCO v0.0.2 Alpha

Todas las modificaciones notables de la aplicación GESCO (Sistema Integral de Gestión Escolar del IPN) se documentan en este archivo.

## [0.0.2 Alpha] - 2025-02-23

### 🚀 Nuevas Funcionalidades
- **Paso de Fotografía del Estudiante (`PasoFoto`):** Se integró un paso dedicado en el asistente de registro para subir o capturar la fotografía oficial del alumno, incluyendo vista previa circular, opciones de cámara/archivo y los requisitos oficiales del IPN.
- **Respaldo Dinámico para Municipios de Nacimiento:** En el registro de datos personales, al detectar el estado de nacimiento mediante el CURP, se despliega automáticamente el catálogo oficial de municipios de Zacatecas, o se habilita un campo de texto libre para cualquier otra entidad federativa.
- **RFC Autocompletado y Editable:** El RFC se rellena de forma automática a partir del CURP ingresado, pero se mantiene completamente editable por el usuario.
- **Banner Académico de Reinscripción:** Incorporación de indicadores del periodo de reinscripción (ej. `2025-2`) y cálculo automático del semestre que cursará el alumno.

### 💡 Mejoras Generales en Experiencia de Usuario (UX)
- **Asistente de Reinscripción de 3 Pasos Simplificado:** Se reestructuró la reinscripción en un flujo lineal y claro (Paso 1: Datos y Domicilio del Alumno, Paso 2: Datos y Domicilio del Tutor, Paso 3: Verificación, Avatar, Descarga de Comprobante PDF y Finalización).
- **Diseño de Paneles en Tarjetas Flotantes (Material 3):** Toda la interfaz de acceso, registro, inicio y trámites fue rediseñada con tarjetas limpias, bordes sutiles, sombras suaves y la paleta de colores institucional del IPN (Guinda `#731C24` y Dorado `#D49A2A`).
- **Campos de Formulario Optimizados (*Stacked Labels*):** Se rediseñaron los formularios de los asistentes con etiquetas superiores y campos de entrada con retroalimentación visual clara y textos de ayuda contextuales.
- **Navegación Intuitiva y Sin Duicidades:** Se eliminaron botones redundantes y se mejoraron las acciones primarias y secundarias en pantallas clave.

### ✅ Pruebas y Verificación
- **Suite de Pruebas Automatizadas:** Se ejecutó y verificó la suite completa de pruebas unitarias y de widgets con `flutter test`, obteniendo éxito total (**`All tests passed!`**).
