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
  ('여성 두피스켈프(커트포함)', 45000, '컷', 8, true),
  ('남성 베이직펌', 60000, '펌', 1, true),
  ('남성 프리미엄 베이직펌', 70000, '펌', 2, true),
  ('앞머리펌', 35000, '펌', 3, true),
  ('앞머리매직', 45000, '펌', 4, true),
  ('다운펌', 35000, '펌', 5, true),
  ('여성 베이직펌', 70000, '펌', 6, true),
  ('여성 프리미엄 베이직펌', 80000, '펌', 7, true),
  ('뿌리볼륨펌', 60000, '펌', 8, true),
  ('디지털, 셋팅', 100000, '열펌', 1, true),
  ('프리미엄 디지털 셋팅', 120000, '열펌', 2, true),
  ('남성 볼륨매직', 90000, '열펌', 3, true),
  ('남성 프리미엄 볼륨매직', 110000, '열펌', 4, true),
  ('매직', 100000, '열펌', 5, true),
  ('프리미엄 매직', 120000, '열펌', 6, true),
  ('여성 볼륨매직', 110000, '열펌', 7, true),
  ('여성 프리미엄 볼륨매직', 130000, '열펌', 8, true),
  ('매직셋팅', 140000, '열펌', 9, true),
  ('프리미엄 매직셋팅', 160000, '열펌', 10, true),
  ('뿌리염색', 45000, '염색', 1, true),
  ('프리미엄 뿌리염색', 55000, '염색', 2, true),
  ('남성컬러', 60000, '염색', 3, true),
  ('남성 프리미엄 컬러', 70000, '염색', 4, true),
  ('남성 탈색', 70000, '염색', 5, true),
  ('여성 컬러', 70000, '염색', 6, true),
  ('여성 프리미엄 컬러', 80000, '염색', 7, true),
  ('여자 탈색', 70000, '염색', 8, true),
  ('메니큐어,왁싱', 70000, '염색', 9, true),
  ('염색 시 커트 만원', 10000, '염색', 10, true),
  ('앰플큐티클영양(펌/염색 시 선택가능)', 10000, '클리닉', 1, true),
  ('하오니코약식', 50000, '클리닉', 2, true),
  ('하오니코클리닉', 80000, '클리닉', 3, true),
  ('복구클리닉', 160000, '클리닉', 4, true),
  ('두피스켈프', 40000, '클리닉', 5, true),
  ('탈모케어솔루션', 50000, '클리닉', 6, true)
on conflict (name) do nothing;
