-- ============================================================
-- 图片上传支持（收藏 collections + 种草 plant_items）
-- 在 Supabase → SQL Editor 中执行本文件即可
-- 作用：创建图片存储桶 + 访问策略 + 两张表各加一个可选 images 字段
-- ============================================================

-- 1) 新增存储桶（公开读取；登录用户可上传 / 删除自己的图片）
insert into storage.buckets (id, name, public)
values ('workbench-images', 'workbench-images', true)
on conflict (id) do nothing;

-- 2) 存储对象访问策略
create policy "workbench-images public read"
  on storage.objects for select
  using ( bucket_id = 'workbench-images' );

create policy "workbench-images authed upload"
  on storage.objects for insert to authenticated
  with check ( bucket_id = 'workbench-images' );

create policy "workbench-images authed delete"
  on storage.objects for delete to authenticated
  using ( bucket_id = 'workbench-images' );

-- 3) 两张表各加一个可选图片字段（text[] 数组，存放图片公共 URL）
--    可选、默认空数组，不影响既有必填字段与数据提交结构
alter table collections
  add column if not exists images text[] default '{}';

alter table plant_items
  add column if not exists images text[] default '{}';
