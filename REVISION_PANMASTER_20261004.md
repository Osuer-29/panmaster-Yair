# PanMaster — revisión y activación 2026-10-04

## Correcciones realizadas

- Se eliminaron conflictos de merge que impedían interpretar `package.json`, `vite.config.ts` y `src/App.tsx`.
- Se corrigió la configuración de Vite para producir un build normal en `dist/` y funcionar con rutas relativas.
- Se alineó el flujo de recetas con la RPC `save_panmaster_recipe`.
- La migración `supabase/migrations/20261004_recipes_stock_traceability.sql` ahora también asegura:
  - columnas adicionales que usa el frontend en `products`;
  - `suppliers.name`;
  - `units_of_measure`;
  - `product_categories`;
  - RPC `delete_product_with_movements`;
  - RPC `clear_inventory_products`;
  - permisos/RLS para los catálogos.
- Se mantuvo el guardado transaccional de movimientos y la trazabilidad.
- No se incluyó `.env` en el paquete de distribución.

## Supabase: orden recomendado

Sobre una base que ya tiene datos, NO ejecutes `schema.sql` ni `supabase_schema.sql` completos.

Ejecuta solamente:

1. `supabase/migrations/20261004_recipes_stock_traceability.sql`
2. `supabase/employee_custom_labels.sql` si vas a utilizar las etiquetas personalizadas de empleados.

La primera migración es idempotente y está diseñada para actualizar una instalación existente sin recalcular los movimientos históricos.

Después de ejecutarla, en Supabase > SQL Editor puedes verificar las RPC principales:

```sql
SELECT
  n.nspname AS schema_name,
  p.proname AS function_name,
  pg_get_function_identity_arguments(p.oid) AS arguments
FROM pg_proc p
JOIN pg_namespace n ON n.oid = p.pronamespace
WHERE n.nspname = 'public'
  AND p.proname IN (
    'save_panmaster_recipe',
    'record_panmaster_inventory_batch',
    'delete_inventory_movement_reversibly',
    'delete_product_with_movements',
    'clear_inventory_products'
  )
ORDER BY p.proname;
```

También puedes verificar catálogos:

```sql
SELECT id, code, name_es, active
FROM public.units_of_measure
ORDER BY name_es;

SELECT id, name_es, active
FROM public.product_categories
ORDER BY name_es;
```

## Importante

No ejecutes después las versiones antiguas de:

- `supabase/fix_inventory_movement_stock_trigger.sql`
- `supabase/delete_inventory_movement_reversibly.sql`

porque la migración 20261004 contiene las versiones actuales del trigger y de la reversión.

`supabase/schema.sql` y `supabase/supabase_schema.sql` son esquemas base/legado y además son duplicados entre sí; no deben usarse como una migración incremental sobre una base que ya está funcionando.

## Verificación local

El chequeo de TypeScript (`tsc --noEmit`) pasó después de corregir los conflictos. El build Vite no pudo terminar en este entorno porque el ZIP traía `node_modules` de Windows y Rollup necesita sus binarios nativos de Linux; en tu PC debes reinstalar dependencias:

```powershell
Remove-Item -Recurse -Force node_modules
npm ci
npm run build
```

En PowerShell usa estos comandos por separado; no dependas de `&&`.

No compartas `.env` ni una clave `service_role`. El proyecto corregido deja `.env` fuera del control de Git.
