-- Run in Supabase SQL Editor

create table if not exists public.bookings (
  id uuid primary key default gen_random_uuid(),
  customer_name text not null,
  phone text not null,
  service text not null,
  date date not null,
  time_label text not null,
  status text not null default 'pending',
  created_at timestamptz not null default now(),
  auto_approved boolean not null default false
);

create index if not exists bookings_date_time_idx
  on public.bookings (date, time_label);

alter table public.bookings enable row level security;

-- Public insert (customers can create bookings)
create policy if not exists "bookings_insert_public"
  on public.bookings
  for insert
  to anon, authenticated
  with check (true);

-- Public read/update (temporary until admin auth UI is added)
create policy if not exists "bookings_read_public"
  on public.bookings
  for select
  to anon, authenticated
  using (true);

create policy if not exists "bookings_update_public"
  on public.bookings
  for update
  to anon, authenticated
  using (true)
  with check (true);
