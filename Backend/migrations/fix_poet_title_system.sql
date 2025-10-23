-- ============================================
-- 修复诗人称号系统
-- 将数据库的称号系统更新为与客户端一致
-- ============================================

-- 更新诗人称号计算函数
CREATE OR REPLACE FUNCTION public.update_poet_title()
RETURNS TRIGGER AS $$
DECLARE
  new_title TEXT;
BEGIN
  -- 根据诗歌总数确定称号（与客户端 PoetTitle.swift 保持一致）
  IF NEW.total_poems >= 500 THEN
    new_title := '谪仙诗人';  -- 500+首
  ELSIF NEW.total_poems >= 201 THEN
    new_title := '山河诗人';  -- 201-500首
  ELSIF NEW.total_poems >= 101 THEN
    new_title := '登高诗人';  -- 101-200首
  ELSIF NEW.total_poems >= 51 THEN
    new_title := '望月诗人';  -- 51-100首
  ELSIF NEW.total_poems >= 21 THEN
    new_title := '寻梅诗人';  -- 21-50首
  ELSIF NEW.total_poems >= 11 THEN
    new_title := '听雨诗人';  -- 11-20首
  ELSIF NEW.total_poems >= 6 THEN
    new_title := '寻山诗人';  -- 6-10首
  ELSIF NEW.total_poems >= 1 THEN
    new_title := '初见诗人';  -- 1-5首
  ELSE
    new_title := '初见诗人';  -- 默认
  END IF;
  
  NEW.poet_title := new_title;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 更新所有现有用户的称号（基于他们当前的诗歌数量）
UPDATE public.profiles
SET 
  poet_title = CASE
    WHEN total_poems >= 500 THEN '谪仙诗人'
    WHEN total_poems >= 201 THEN '山河诗人'
    WHEN total_poems >= 101 THEN '登高诗人'
    WHEN total_poems >= 51 THEN '望月诗人'
    WHEN total_poems >= 21 THEN '寻梅诗人'
    WHEN total_poems >= 11 THEN '听雨诗人'
    WHEN total_poems >= 6 THEN '寻山诗人'
    ELSE '初见诗人'
  END,
  updated_at = NOW()
WHERE poet_title IN ('拾字诗人', '听风诗人', '踏雪诗人', '望山诗人', '观海诗人')
   OR poet_title IS NULL;

-- 验证更新
SELECT 
  poet_title,
  COUNT(*) as user_count,
  MIN(total_poems) as min_poems,
  MAX(total_poems) as max_poems
FROM public.profiles
GROUP BY poet_title
ORDER BY MIN(total_poems);

