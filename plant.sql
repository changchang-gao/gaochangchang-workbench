-- ============================================================
-- 种草模块建表 SQL (plant_categories + plant_items)
-- 在 Supabase → SQL Editor 中执行本文件即可
-- ============================================================

-- 1) 建表：大类（如 奶茶 / 美妆 / 数码）
create table plant_categories (
  id uuid default gen_random_uuid() primary key,
  workspace_id uuid references workspaces(id) not null,
  name text not null,
  sort_order int default 0,
  created_by uuid references auth.users(id),
  created_at timestamp with time zone default now()
);

-- 2) 建表：商品条目（品名 / 商家 / 备注 + 种草/拔草 状态）
create table plant_items (
  id uuid default gen_random_uuid() primary key,
  workspace_id uuid references workspaces(id) not null,
  category_id uuid references plant_categories(id) on delete cascade,
  name text not null,
  merchant text,
  note text,
  status text check (status in ('planted', 'pulled')),
  created_by uuid references auth.users(id),
  created_at timestamp with time zone default now()
);

-- 3) 开启行级安全（RLS），与 grudges 等表保持一致
alter table plant_categories enable row level security;
alter table plant_items enable row level security;

-- 4) 访问策略：仅当前工作空间的成员可读写（基于 workspace_members 成员关系）
--    若你的其他表（如 collections）使用了不同的策略，请把下面八段改成与之相同的形式。

create policy "plant_categories_select" on plant_categories
  for select using (
    exists (
      select 1 from workspace_members wm
      where wm.workspace_id = plant_categories.workspace_id
        and wm.user_id = auth.uid()
    )
  );

create policy "plant_categories_insert" on plant_categories
  for insert with check (
    exists (
      select 1 from workspace_members wm
      where wm.workspace_id = plant_categories.workspace_id
        and wm.user_id = auth.uid()
    )
  );

create policy "plant_categories_update" on plant_categories
  for update using (
    exists (
      select 1 from workspace_members wm
      where wm.workspace_id = plant_categories.workspace_id
        and wm.user_id = auth.uid()
    )
  );

create policy "plant_categories_delete" on plant_categories
  for delete using (
    exists (
      select 1 from workspace_members wm
      where wm.workspace_id = plant_categories.workspace_id
        and wm.user_id = auth.uid()
    )
  );

create policy "plant_items_select" on plant_items
  for select using (
    exists (
      select 1 from workspace_members wm
      where wm.workspace_id = plant_items.workspace_id
        and wm.user_id = auth.uid()
    )
  );

create policy "plant_items_insert" on plant_items
  for insert with check (
    exists (
      select 1 from workspace_members wm
      where wm.workspace_id = plant_items.workspace_id
        and wm.user_id = auth.uid()
    )
  );

create policy "plant_items_update" on plant_items
  for update using (
    exists (
      select 1 from workspace_members wm
      where wm.workspace_id = plant_items.workspace_id
        and wm.user_id = auth.uid()
    )
  );

create policy "plant_items_delete" on plant_items
  for delete using (
    exists (
      select 1 from workspace_members wm
      where wm.workspace_id = plant_items.workspace_id
        and wm.user_id = auth.uid()
    )
  );
