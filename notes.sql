-- ============================================================
-- 想法沉淀（notes）建表 SQL
-- 在 Supabase → SQL Editor 中粘贴执行本文件即可。
-- 已用 if not exists 包裹，可重复执行。
-- ============================================================

-- 1) 建表
create table if not exists notes (
  id uuid default gen_random_uuid() primary key,
  workspace_id uuid references workspaces(id) on delete cascade not null,
  created_by uuid references auth.users(id),
  title text not null default '',
  body text default '',
  drawing text,                       -- 手绘内容以 PNG base64 data URL 存储（可选）
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now()
);

-- 2) 开启行级安全（RLS），与 grudges / collections 等表保持一致
alter table notes enable row level security;

-- 3) 访问策略：仅当前工作空间的成员可读写（基于 workspace_members 成员关系）
create policy "notes_select" on notes
  for select using (
    exists (
      select 1 from workspace_members wm
      where wm.workspace_id = notes.workspace_id
        and wm.user_id = auth.uid()
    )
  );

create policy "notes_insert" on notes
  for insert with check (
    exists (
      select 1 from workspace_members wm
      where wm.workspace_id = notes.workspace_id
        and wm.user_id = auth.uid()
    )
  );

create policy "notes_update" on notes
  for update using (
    exists (
      select 1 from workspace_members wm
      where wm.workspace_id = notes.workspace_id
        and wm.user_id = auth.uid()
    )
  );

create policy "notes_delete" on notes
  for delete using (
    exists (
      select 1 from workspace_members wm
      where wm.workspace_id = notes.workspace_id
        and wm.user_id = auth.uid()
    )
  );

-- 4) 让 Supabase 实时订阅（realtime）能推送 notes 表的变更
alter publication supabase_realtime add table notes;
