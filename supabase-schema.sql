create table if not exists public.daily_plans (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  text text not null,
  active boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists public.daily_entries (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  entry_date date not null,
  checked_at timestamptz,
  diary text not null default '',
  encouragement text not null default '',
  completed_tasks text[] not null default '{}',
  missed_tasks text[] not null default '{}',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, entry_date)
);

alter table public.daily_plans enable row level security;
alter table public.daily_entries enable row level security;

create policy "Users can read their own plans"
  on public.daily_plans
  for select
  using (auth.uid() = user_id);

create policy "Users can create their own plans"
  on public.daily_plans
  for insert
  with check (auth.uid() = user_id);

create policy "Users can update their own plans"
  on public.daily_plans
  for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "Users can read their own entries"
  on public.daily_entries
  for select
  using (auth.uid() = user_id);

create policy "Users can create their own entries"
  on public.daily_entries
  for insert
  with check (auth.uid() = user_id);

create policy "Users can update their own entries"
  on public.daily_entries
  for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create index if not exists daily_plans_user_active_idx
  on public.daily_plans (user_id, active, created_at);

create index if not exists daily_entries_user_date_idx
  on public.daily_entries (user_id, entry_date desc);
