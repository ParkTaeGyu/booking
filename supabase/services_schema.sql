-- Run in Supabase SQL Editor

create table if not exists public.services (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  price integer not null,
  category text not null default '기타',
  order_index integer not null default 0,
  active boolean not null default true
);

create index if not exists services_category_order_idx
  on public.services (category, order_index);

create unique index if not exists services_name_unique
  on public.services (name);

alter table public.services enable row level security;

drop policy if exists services_read_public on public.services;
drop policy if exists services_write_public on public.services;

create policy services_read_public
  on public.services
  for select
  to anon, authenticated
  using (true);

create policy services_write_public
  on public.services
  for all
  to anon, authenticated
  using (true)
  with check (true);

insert into public.services (name, price, category, order_index, active)
values
  ('남성 사이드다운펌(커트포함)', 40000, '컷', 1, true),
  ('앞머리컷', 2000, '컷', 2, true),
  ('남성컷', 20000, '컷', 3, true),
  ('남학생 컷', 18000, '컷', 4, true),
  ('남성 두피스켈프(커트 포함)', 40000, '컷', 5, true),
  ('여성컷', 23000, '컷', 6, true),
  ('여학생 컷', 20000, '컷', 7, true),
  ('여성 두피스켈프(커트포함)', 45000, '컷', 8, true)
on conflict (name) do nothing;
