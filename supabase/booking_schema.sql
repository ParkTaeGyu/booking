-- Run in Supabase SQL Editor

create table if not exists public.bookings (
  id uuid primary key default gen_random_uuid(),
  customer_name text not null,
  phone text not null,
  gender text not null default '미선택',
  service text not null,
  service_price integer not null default 0,
  date date not null,
  time_label text not null,
  status text not null default 'pending',
  created_at timestamptz not null default now(),
  auto_approved boolean not null default false
);

alter table if exists public.bookings
  add column if not exists service_price integer not null default 0;

create index if not exists bookings_date_time_idx
  on public.bookings (date, time_label);

alter table public.bookings enable row level security;

drop policy if exists bookings_insert_public on public.bookings;
drop policy if exists bookings_read_public on public.bookings;
drop policy if exists bookings_update_public on public.bookings;

create policy bookings_insert_public
  on public.bookings
  for insert
  to anon, authenticated
  with check (true);

create policy bookings_read_public
  on public.bookings
  for select
  to anon, authenticated
  using (true);

create policy bookings_update_public
  on public.bookings
  for update
  to anon, authenticated
  using (true)
  with check (true);
