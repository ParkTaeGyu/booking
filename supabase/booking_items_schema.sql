-- Run in Supabase SQL Editor

create table if not exists public.booking_items (
  id uuid primary key default gen_random_uuid(),
  booking_id uuid not null references public.bookings(id) on delete cascade,
  service_id uuid not null references public.services(id),
  service_name text not null,
  service_price integer not null,
  category text not null default '기타',
  created_at timestamptz not null default now()
);

create index if not exists booking_items_booking_idx
  on public.booking_items (booking_id);

alter table public.booking_items enable row level security;

drop policy if exists booking_items_read_public on public.booking_items;
drop policy if exists booking_items_write_public on public.booking_items;

create policy booking_items_read_public
  on public.booking_items
  for select
  to anon, authenticated
  using (true);

create policy booking_items_write_public
  on public.booking_items
  for all
  to anon, authenticated
  using (true)
  with check (true);
