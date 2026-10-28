-- PanMaster: orden manual de empleados.
-- Migración aditiva y segura: no borra ni modifica datos laborales existentes.
-- Ejecutar una sola vez en Supabase SQL Editor antes de usar "Orden manual".

alter table public.employees
  add column if not exists display_order integer;

-- Inicializa solo las filas sin orden previo, conservando cualquier orden manual ya guardado.
with employee_order as (
  select id,
         row_number() over (order by lower(coalesce(full_name, '')), id)::integer as position
  from public.employees
)
update public.employees as employee
set display_order = employee_order.position
from employee_order
where employee.id = employee_order.id
  and employee.display_order is null;

alter table public.employees
  alter column display_order set default 1000;

alter table public.employees
  alter column display_order set not null;

create index if not exists employees_display_order_idx
  on public.employees (display_order, full_name);
