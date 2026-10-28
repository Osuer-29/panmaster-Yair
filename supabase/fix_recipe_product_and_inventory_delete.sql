-- PANMASTER: borrado seguro de productos e inventario
-- Ejecutar una vez en Supabase SQL Editor con una cuenta propietaria.
-- No borra nada al instalar este archivo; solo crea las funciones que usa la aplicación.

BEGIN;

CREATE OR REPLACE FUNCTION public.delete_product_with_movements(p_product_id uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
  v_actor uuid := public.panmaster_require_admin();
BEGIN
  IF p_product_id IS NULL THEN
    RAISE EXCEPTION 'Debe indicar el producto';
  END IF;

  PERFORM 1 FROM public.products WHERE id = p_product_id FOR UPDATE;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'El producto no existe';
  END IF;

  -- Primero se quitan los movimientos porque inventory_movements usa ON DELETE RESTRICT.
  DELETE FROM public.inventory_movements WHERE product_id = p_product_id;

  -- Algunas instalaciones antiguas pudieron tener una relación opcional desde recetas.
  -- Si existe la columna, se desvincula antes de borrar el producto.
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'recipes' AND column_name = 'product_id'
  ) THEN
    EXECUTE 'UPDATE public.recipes SET product_id = NULL WHERE product_id = $1' USING p_product_id;
  END IF;

  DELETE FROM public.products WHERE id = p_product_id;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'No se pudo eliminar el producto';
  END IF;
END;
$$;

CREATE OR REPLACE FUNCTION public.clear_inventory_products(p_module_id uuid DEFAULT NULL)
RETURNS integer
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
  v_actor uuid := public.panmaster_require_admin();
  v_product_id uuid;
  v_count integer := 0;
BEGIN
  -- El orden estable evita bloqueos cruzados cuando hay varias operaciones simultáneas.
  FOR v_product_id IN
    SELECT id
    FROM public.products
    WHERE p_module_id IS NULL OR module_id = p_module_id
    ORDER BY id
    FOR UPDATE
  LOOP
    DELETE FROM public.inventory_movements WHERE product_id = v_product_id;

    IF EXISTS (
      SELECT 1 FROM information_schema.columns
      WHERE table_schema = 'public' AND table_name = 'recipes' AND column_name = 'product_id'
    ) THEN
      EXECUTE 'UPDATE public.recipes SET product_id = NULL WHERE product_id = $1' USING v_product_id;
    END IF;

    DELETE FROM public.products WHERE id = v_product_id;
    v_count := v_count + 1;
  END LOOP;

  RETURN v_count;
END;
$$;

REVOKE ALL ON FUNCTION public.delete_product_with_movements(uuid) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.clear_inventory_products(uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.delete_product_with_movements(uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.clear_inventory_products(uuid) TO authenticated;

NOTIFY pgrst, 'reload schema';
COMMIT;
