-- ============================================================
-- 小本本表 (grudges) 建表 SQL
-- 在 Supabase → SQL Editor 中执行本文件即可
-- ============================================================

-- 1) 建表
create table grudges (
  id uuid default gen_random_uuid() primary key,
  workspace_id uuid references workspaces(id) not null,
  title text not null,
  content text,
  created_by uuid references auth.users(id),
  created_at timestamp with time zone default now()
);

-- 2) 开启行级安全（RLS），与 collections 等表保持一致
alter table grudges enable row level security;

-- 3) 访问策略：仅当前工作空间的成员可读写（基于 workspace_members 成员关系）
--    若你的 collections 表使用了不同的策略，请把下面四段改成与之相同的形式。

create policy "grudges_select" on grudges
  for select using (
    exists (
      select 1 from workspace_members wm
      where wm.workspace_id = grudges.workspace_id
        and wm.user_id = auth.uid()
    )
  );

create policy "grudges_insert" on grudges
  for insert with check (
    exists (
      select 1 from workspace_members wm
      where wm.workspace_id = grudges.workspace_id
        and wm.user_id = auth.uid()
    )
  );

create policy "grudges_update" on grudges
  for update using (
    exists (
      select 1 from workspace_members wm
      where wm.workspace_id = grudges.workspace_id
        and wm.user_id = auth.uid()
    )
  );

create policy "grudges_delete" on grudges
  for delete using (
    exists (
      select 1 from workspace_members wm
      where wm.workspace_id = grudges.workspace_id
        and wm.user_id = auth.uid()
    )
  );
