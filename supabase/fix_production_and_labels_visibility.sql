-- PanMaster: make production labels and shared custom labels visible to active staff.
-- Safe/additive: changes access policies only; it does NOT insert, update, or delete business data.
-- Run once in Supabase Dashboard > SQL Editor, after checking the target project.

BEGIN;

-- Inventory module/product lookup is read-only and is needed by the employee label picker.
ALTER TABLE public.inventory_modules ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS panmaster_active_staff_read_modules_for_labels ON public.inventory_modules;
DROP POLICY IF EXISTS panmaster_active_users_read_modules_for_labels ON public.inventory_modules;
CREATE POLICY panmaster_active_staff_read_modules_for_labels
  ON public.inventory_modules
  FOR SELECT
  TO authenticated
  USING (
    active = true
    AND EXISTS (
      SELECT 1
      FROM public.profiles p
      WHERE p.id = auth.uid()
        AND p.active = true
        AND p.role::text IN ('superadmin', 'employee')
    )
  );
DROP POLICY IF EXISTS panmaster_active_staff_read_products_for_labels ON public.products;
DROP POLICY IF EXISTS panmaster_active_users_read_products_for_labels ON public.products;
CREATE POLICY panmaster_active_staff_read_products_for_labels
  ON public.products
  FOR SELECT
  TO authenticated
  USING (
    active = true
    AND EXISTS (
      SELECT 1
      FROM public.profiles p
      WHERE p.id = auth.uid()
        AND p.active = true
        AND p.role::text IN ('superadmin', 'employee')
    )
  );
GRANT SELECT ON public.inventory_modules, public.products TO authenticated;

-- Production records created by the superadmin must be readable by employees for label printing.
ALTER TABLE public.final_products ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS panmaster_active_staff_read_final_products ON public.final_products;
CREATE POLICY panmaster_active_staff_read_final_products
  ON public.final_products
  FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1
      FROM public.profiles p
      WHERE p.id = auth.uid()
        AND p.active = true
        AND p.role::text IN ('superadmin', 'employee')
    )
  );
GRANT SELECT ON public.final_products TO authenticated;

-- Custom labels are shared work instructions, not private user records.
-- Any active employee/superadmin can read them; each person can still insert only as themselves,
-- and the existing superadmin-only delete policy remains unchanged.
DO $$
BEGIN
  IF to_regclass('public.employee_custom_labels') IS NOT NULL THEN
    EXECUTE 'ALTER TABLE public.employee_custom_labels ENABLE ROW LEVEL SECURITY';
    EXECUTE 'DROP POLICY IF EXISTS "Employees and admins can view custom labels" ON public.employee_custom_labels';
    EXECUTE 'DROP POLICY IF EXISTS panmaster_active_staff_read_custom_labels ON public.employee_custom_labels';
    EXECUTE $policy$
      CREATE POLICY panmaster_active_staff_read_custom_labels
        ON public.employee_custom_labels
        FOR SELECT
        TO authenticated
        USING (
          EXISTS (
            SELECT 1
            FROM public.profiles p
            WHERE p.id = auth.uid()
              AND p.active = true
              AND p.role::text IN ('superadmin', 'employee')
          )
        )
    $policy$;
    EXECUTE 'GRANT SELECT ON public.employee_custom_labels TO authenticated';
  END IF;
END $$;

COMMIT;
