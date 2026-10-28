# Actualización segura de PanMaster — 28 de octubre de 2026

## Cambios incluidos

- La pantalla de empleados ordena por defecto los puestos reconocidos de mayor responsabilidad a menor responsabilidad. Para un puesto cuyo nombre no coincida con las categorías reconocidas, se conserva el empleado y se coloca después de los puestos reconocidos; los empates se ordenan por nombre.
- El horario semanal presenta una fila por empleado y los siete días como columnas. Cada día muestra estado, entrada, salida y minutos de descanso. El horario para imprimir mantiene el mismo formato de una fila por persona.
- Se añadió selección de orden: rango, manual y nombre A–Z. El orden manual se guarda en Supabase y se comparte entre equipos después de aplicar la migración SQL indicada abajo.
- Las etiquetas térmicas 4 × 6 pulgadas ya no imprimen “Prepared by” ni textos de relleno en la parte inferior. El tamaño de letra se ajusta a nombres largos y el documento de impresión se limita a una sola etiqueta.
- La marca visible de la aplicación se cambió de “Panadería” a “Hola Yair”.
- Los registros diarios individuales del horario se mantienen disponibles para editar o eliminar, pero quedan contraídos debajo de la cuadrícula semanal para que no se repita el nombre del empleado en la vista principal.

## Paso necesario para habilitar el orden manual persistente

El orden automático por rango y la impresión del horario funcionan sin cambiar las tablas actuales. Para habilitar el guardado del orden manual entre computadoras, abre Supabase → SQL Editor y ejecuta una sola vez el contenido de:

`supabase/migrations/20261028_employee_display_order.sql`

La migración añade únicamente `employees.display_order`, inicializa el orden para empleados que aún no lo tengan y crea un índice. No elimina empleados, turnos, productos, movimientos ni ningún otro dato. No hace falta volver a ejecutar `schema.sql` ni recrear la base de datos.

## Comprobación local

Después de extraer el ZIP en Windows, ejecuta `ACTUALIZAR_Y_PROBAR.bat` o abre una terminal en la carpeta del proyecto. Esto recompila `publicacion/panmaster.js` para que el archivo `index.html` y la versión publicada no sigan usando el paquete JavaScript anterior.

Desde la carpeta del proyecto también puedes usar:

```powershell
npm install
npm run build
npm run dev
```

Antes de publicar, conserva la configuración `.env` propia del proyecto con `VITE_SUPABASE_URL` y `VITE_SUPABASE_ANON_KEY`. No compartas la clave `service_role` en el navegador.
