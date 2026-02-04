-- Run in Supabase SQL Editor

create table if not exists public.blocked_slots (
  id uuid primary key default gen_random_uuid(),
  date date not null,
  time_label text,
  created_at timestamptz not null default now()
);

create index if not exists blocked_slots_date_idx
  on public.blocked_slots (date, time_label);

alter table public.blocked_slots enable row level security;

drop policy if exists blocked_slots_insert_public on public.blocked_slots;
drop policy if exists blocked_slots_read_public on public.blocked_slots;
drop policy if exists blocked_slots_delete_public on public.blocked_slots;

create policy blocked_slots_insert_public
  on public.blocked_slots
  for insert
  to anon, authenticated
  with check (true);

create policy blocked_slots_read_public
  on public.blocked_slots
  for select
  to anon, authenticated
  using (true);

create policy blocked_slots_delete_public
  on public.blocked_slots
  for delete
  to anon, authenticated
  using (true);
