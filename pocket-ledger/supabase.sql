-- 在 Supabase SQL Editor 中一次性执行。
-- 共享码通过 Supabase 浏览器端允许的 x-client-info 请求头参与 RLS。

create table if not exists public.ledger_entries (
  id text primary key,
  share_code text not null check (char_length(share_code) >= 12),
  type text not null check (type in ('expense','income')),
  category text not null,
  emoji text not null default '📦',
  amount numeric(12,2) not null check (amount > 0),
  note text,
  date date not null,
  created_at timestamptz not null,
  updated_at timestamptz not null,
  deleted_at timestamptz,
  device_id text
);

create table if not exists public.ledger_books (
  id text primary key,
  share_code text not null check (char_length(share_code) >= 12),
  month text not null check (month ~ '^\\d{4}-(0[1-9]|1[0-2])$'),
  name text not null default '我们的生活',
  created_at timestamptz not null,
  updated_at timestamptz not null,
  deleted_at timestamptz
);

create unique index if not exists ledger_books_share_month_key on public.ledger_books(share_code, month);

create index if not exists ledger_entries_share_code_idx on public.ledger_entries(share_code);
create index if not exists ledger_books_share_code_idx on public.ledger_books(share_code);
alter table public.ledger_entries enable row level security;
alter table public.ledger_books enable row level security;

create or replace function public.request_share_code() returns text
language sql stable as $$
  select coalesce(current_setting('request.headers', true)::json->>'x-client-info', '');
$$;

drop policy if exists "public shared ledger read" on public.ledger_entries;
drop policy if exists "public shared ledger insert" on public.ledger_entries;
drop policy if exists "public shared ledger update" on public.ledger_entries;
drop policy if exists "shared ledger read" on public.ledger_entries;
drop policy if exists "shared ledger insert" on public.ledger_entries;
drop policy if exists "shared ledger update" on public.ledger_entries;
drop policy if exists "shared books read" on public.ledger_books;
drop policy if exists "shared books insert" on public.ledger_books;
drop policy if exists "shared books update" on public.ledger_books;

create policy "shared ledger read" on public.ledger_entries for select to anon
  using (share_code = public.request_share_code() and char_length(public.request_share_code()) >= 12);
create policy "shared ledger insert" on public.ledger_entries for insert to anon
  with check (share_code = public.request_share_code() and char_length(share_code) >= 12);
create policy "shared ledger update" on public.ledger_entries for update to anon
  using (share_code = public.request_share_code())
  with check (share_code = public.request_share_code() and char_length(share_code) >= 12);

create policy "shared books read" on public.ledger_books for select to anon
  using (share_code = public.request_share_code() and char_length(public.request_share_code()) >= 12);
create policy "shared books insert" on public.ledger_books for insert to anon
  with check (share_code = public.request_share_code() and char_length(share_code) >= 12);
create policy "shared books update" on public.ledger_books for update to anon
  using (share_code = public.request_share_code())
  with check (share_code = public.request_share_code() and char_length(share_code) >= 12);
