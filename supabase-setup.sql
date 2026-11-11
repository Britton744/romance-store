-- ROMANCE STORE / Supabase setup
-- Run in Supabase SQL Editor. Then create an admin user in Authentication > Users,
-- copy that user's UUID, and run the INSERT shown at the bottom.

create extension if not exists pgcrypto;

create table if not exists public.categories (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  slug text unique,
  description text default '',
  image_url text default '',
  background_image_url text default '',
  sort_order integer default 0,
  active boolean default true,
  created_at timestamptz default now()
);

create table if not exists public.products (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  description text default '',
  price numeric(10,2) not null default 0,
  compare_at_price numeric(10,2),
  images text[] not null default '{}',
  category_id uuid references public.categories(id) on delete set null,
  stock integer not null default 0,
  active boolean not null default true,
  featured boolean not null default false,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number bigint generated always as identity,
  customer_name text not null,
  phone text not null,
  email text default '',
  city text not null,
  district text not null,
  national_address text default '',
  address text not null,
  items jsonb not null default '[]',
  subtotal numeric(10,2) not null default 0,
  shipping numeric(10,2) not null default 0,
  total numeric(10,2) not null default 0,
  status text not null default 'جديد',
  created_at timestamptz default now()
);

create table if not exists public.store_settings (
  id integer primary key default 1 check (id = 1),
  store_name text default 'متجر الرومانسية للألعاب الزوجية',
  store_name_en text default 'ROMANCE STORE',
  phone text default '',
  whatsapp text default '',
  email text default '',
  logo_url text default '',
  hero_title text default 'لحظات أقرب… وخصوصية تامة',
  hero_description text default 'تسوّق بسهولة مع تغليف discreet وخيارات توصيل مناسبة',
  about_text text default 'متجر يهتم بتجربة تسوق راقية وخصوصية العملاء.',
  announcement text default 'توصيل لجميع المناطق حسب التغطية',
  theme jsonb not null default '{"primary":"#ef476f","secondary":"#a855f7","accent":"#f4b6c8","background":"#160b16"}',
  page_background_url text default '',
  updated_at timestamptz default now()
);
insert into public.store_settings (id) values (1) on conflict (id) do nothing;

create table if not exists public.admin_users (
  user_id uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz default now()
);

create table if not exists public.visitor_events (
  id bigint generated always as identity primary key,
  visited_at timestamptz default now(),
  page text default '/'
);

create or replace function public.is_store_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (select 1 from public.admin_users where user_id = auth.uid());
$$;

alter table public.categories enable row level security;
alter table public.products enable row level security;
alter table public.orders enable row level security;
alter table public.store_settings enable row level security;
alter table public.admin_users enable row level security;
alter table public.visitor_events enable row level security;

drop policy if exists "public read active categories" on public.categories;
create policy "public read active categories" on public.categories for select using (active = true);
drop policy if exists "admin manage categories" on public.categories;
create policy "admin manage categories" on public.categories for all to authenticated using (public.is_store_admin()) with check (public.is_store_admin());

drop policy if exists "public read active products" on public.products;
create policy "public read active products" on public.products for select using (active = true);
drop policy if exists "admin manage products" on public.products;
create policy "admin manage products" on public.products for all to authenticated using (public.is_store_admin()) with check (public.is_store_admin());

drop policy if exists "public create orders" on public.orders;
create policy "public create orders" on public.orders for insert to anon, authenticated with check (true);
drop policy if exists "admin read orders" on public.orders;
create policy "admin read orders" on public.orders for select to authenticated using (public.is_store_admin());
drop policy if exists "admin update orders" on public.orders;
create policy "admin update orders" on public.orders for update to authenticated using (public.is_store_admin()) with check (public.is_store_admin());

drop policy if exists "public read store settings" on public.store_settings;
create policy "public read store settings" on public.store_settings for select using (true);
drop policy if exists "admin update store settings" on public.store_settings;
create policy "admin update store settings" on public.store_settings for update to authenticated using (public.is_store_admin()) with check (public.is_store_admin());

drop policy if exists "admin read admins" on public.admin_users;
create policy "admin read admins" on public.admin_users for select to authenticated using (public.is_store_admin());

drop policy if exists "public record visits" on public.visitor_events;
create policy "public record visits" on public.visitor_events for insert to anon, authenticated with check (true);
drop policy if exists "admin read visits" on public.visitor_events;
create policy "admin read visits" on public.visitor_events for select to authenticated using (public.is_store_admin());

-- Storage bucket for product/category/logo images
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('products-images', 'products-images', true, 5242880, array['image/jpeg','image/png','image/webp','image/gif'])
on conflict (id) do update set public = true;

drop policy if exists "public view store images" on storage.objects;
create policy "public view store images" on storage.objects for select using (bucket_id = 'products-images');
drop policy if exists "admin upload store images" on storage.objects;
create policy "admin upload store images" on storage.objects for insert to authenticated with check (bucket_id = 'products-images' and public.is_store_admin());
drop policy if exists "admin update store images" on storage.objects;
create policy "admin update store images" on storage.objects for update to authenticated using (bucket_id = 'products-images' and public.is_store_admin()) with check (bucket_id = 'products-images' and public.is_store_admin());
drop policy if exists "admin delete store images" on storage.objects;
create policy "admin delete store images" on storage.objects for delete to authenticated using (bucket_id = 'products-images' and public.is_store_admin());

-- AFTER creating the admin account in Authentication > Users:
-- replace UUID below with that account's User UID, then run:
-- insert into public.admin_users (user_id) values ('YOUR-AUTH-USER-UUID') on conflict do nothing;
