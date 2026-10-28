# PanMaster — revisión y corrección final

Se corrigieron errores de integración que impedían compilar y guardar/borrar correctamente.

## Cambios principales

- Eliminados todos los conflictos de Git sin resolver de `App.tsx`, `package.json`, `vite.config.ts` y `.gitignore`.
- Corregido el flujo de guardado de recetas mediante `save_panmaster_recipe`.
- La migración de recetas/inventario ahora incluye las funciones reales usadas por la interfaz:
  - `delete_product_with_movements`
  - `clear_inventory_products`
- El borrado de productos elimina primero sus movimientos para respetar las claves foráneas y después elimina el producto dentro de la misma función segura.
- El vaciado de inventario se realiza producto por producto en orden estable para reducir bloqueos concurrentes.
- Se conserva la trazabilidad/auditoría de los movimientos mediante los triggers existentes.
- El flujo de entradas/salidas mantiene el lote idempotente: reintentar el mismo lote no duplica movimientos ni modifica dos veces el stock.
- Se mantuvieron las funciones existentes de recetas, inventarios, etiquetas, producción, empleados, horarios y exportaciones.
- Se añadió `supabase/fix_recipe_product_and_inventory_delete.sql` para instalaciones de Supabase que ya tengan la base creada y solo necesiten instalar las funciones de borrado.
- `npm ci --dry-run` valida correctamente el `package-lock.json` y contempla los binarios nativos de Rollup para las plataformas soportadas.

## Instalación recomendada

1. No copies el `node_modules` anterior. El ZIP corregido no lo incluye.
2. Ejecuta `npm ci` en el equipo donde se vaya a compilar el sistema.
3. Crea `.env` a partir de `.env.example` y coloca las variables de Supabase.
4. Ejecuta `npm run build`.
5. En Supabase, para una instalación nueva o para aplicar toda la corrección, ejecuta:
   `supabase/migrations/20261004_recipes_stock_traceability.sql`
6. Si la base ya tiene esa migración aplicada y únicamente faltan las funciones de borrado, ejecuta:
   `supabase/fix_recipe_product_and_inventory_delete.sql`

## Verificación

- `npx tsc --noEmit`: OK después de las correcciones.
- Se eliminaron todos los marcadores de conflicto de Git del código fuente.
- El `package-lock.json` es compatible con la instalación limpia mediante `npm ci`.

> Importante: no se incluye `.env` en el paquete corregido. La clave pública de Supabase debe configurarse en el entorno del cliente; nunca se debe incluir una `service_role` en el navegador.
