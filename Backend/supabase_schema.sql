-- ============================================
-- 山海诗馆 - Supabase 数据库设计
-- ============================================

-- 1. 用户表 (users)
-- Supabase Auth 自带 auth.users 表，我们只需扩展
CREATE TABLE public.profiles (
  id UUID REFERENCES auth.users PRIMARY KEY,
  username TEXT UNIQUE NOT NULL,
  display_name TEXT,
  poet_title TEXT DEFAULT '初见诗人',  -- 诗人称号
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- 统计数据
  total_poems INT DEFAULT 0,
  total_likes_received INT DEFAULT 0,
  
  -- 会员信息
  is_premium BOOLEAN DEFAULT FALSE,
  premium_expires_at TIMESTAMP WITH TIME ZONE,
  
  CONSTRAINT username_length CHECK (char_length(username) >= 2 AND char_length(username) <= 20)
);

-- 2. 诗歌表 (poems)
CREATE TABLE public.poems (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- 基本信息
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  author_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  
  -- 时间戳
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- 创作信息
  writing_mode TEXT,  -- 'direct', 'mimic', 'theme'
  tags TEXT[] DEFAULT '{}',
  
  -- AI 点评
  ai_comment TEXT,
  
  -- 状态
  is_published BOOLEAN DEFAULT FALSE,  -- 是否发布到广场
  is_draft BOOLEAN DEFAULT TRUE,       -- 是否为草稿
  
  -- 统计
  like_count INT DEFAULT 0,
  view_count INT DEFAULT 0,
  
  CONSTRAINT content_not_empty CHECK (char_length(content) > 0)
);

-- 3. 点赞表 (likes)
CREATE TABLE public.likes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  poem_id UUID REFERENCES public.poems(id) ON DELETE CASCADE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- 防止重复点赞
  UNIQUE(user_id, poem_id)
);

-- 4. 收藏表 (favorites)
CREATE TABLE public.favorites (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  poem_id UUID REFERENCES public.poems(id) ON DELETE CASCADE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- 防止重复收藏
  UNIQUE(user_id, poem_id)
);

-- 5. 评论表 (comments) - 未来扩展
CREATE TABLE public.comments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  poem_id UUID REFERENCES public.poems(id) ON DELETE CASCADE NOT NULL,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  content TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  CONSTRAINT comment_not_empty CHECK (char_length(content) > 0)
);

-- ============================================
-- 索引优化
-- ============================================

-- 诗歌表索引
CREATE INDEX idx_poems_author ON public.poems(author_id);
CREATE INDEX idx_poems_published ON public.poems(is_published) WHERE is_published = TRUE;
CREATE INDEX idx_poems_created_at ON public.poems(created_at DESC);
CREATE INDEX idx_poems_like_count ON public.poems(like_count DESC);

-- 点赞表索引
CREATE INDEX idx_likes_user ON public.likes(user_id);
CREATE INDEX idx_likes_poem ON public.likes(poem_id);

-- 收藏表索引
CREATE INDEX idx_favorites_user ON public.favorites(user_id);

-- ============================================
-- 触发器：自动更新时间戳
-- ============================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_poems_updated_at BEFORE UPDATE ON public.poems
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- 触发器：点赞计数自动更新
-- ============================================

-- 点赞时：诗歌点赞数 +1，作者总获赞数 +1
CREATE OR REPLACE FUNCTION increment_like_count()
RETURNS TRIGGER AS $$
BEGIN
  -- 更新诗歌点赞数
  UPDATE public.poems
  SET like_count = like_count + 1
  WHERE id = NEW.poem_id;
  
  -- 更新作者总获赞数
  UPDATE public.profiles
  SET total_likes_received = total_likes_received + 1
  WHERE id = (SELECT author_id FROM public.poems WHERE id = NEW.poem_id);
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER on_like_added AFTER INSERT ON public.likes
  FOR EACH ROW EXECUTE FUNCTION increment_like_count();

-- 取消点赞时：诗歌点赞数 -1，作者总获赞数 -1
CREATE OR REPLACE FUNCTION decrement_like_count()
RETURNS TRIGGER AS $$
BEGIN
  -- 更新诗歌点赞数
  UPDATE public.poems
  SET like_count = like_count - 1
  WHERE id = OLD.poem_id;
  
  -- 更新作者总获赞数
  UPDATE public.profiles
  SET total_likes_received = total_likes_received - 1
  WHERE id = (SELECT author_id FROM public.poems WHERE id = OLD.poem_id);
  
  RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER on_like_removed AFTER DELETE ON public.likes
  FOR EACH ROW EXECUTE FUNCTION decrement_like_count();

-- ============================================
-- 触发器：发布诗歌时更新作者诗歌总数
-- ============================================

CREATE OR REPLACE FUNCTION update_author_poem_count()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.is_published = TRUE AND (OLD.is_published IS NULL OR OLD.is_published = FALSE) THEN
    UPDATE public.profiles
    SET total_poems = total_poems + 1
    WHERE id = NEW.author_id;
  ELSIF NEW.is_published = FALSE AND OLD.is_published = TRUE THEN
    UPDATE public.profiles
    SET total_poems = total_poems - 1
    WHERE id = NEW.author_id;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER on_poem_published AFTER INSERT OR UPDATE ON public.poems
  FOR EACH ROW EXECUTE FUNCTION update_author_poem_count();

-- ============================================
-- RLS (Row Level Security) 安全策略
-- ============================================

-- 启用 RLS
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.poems ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.favorites ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.comments ENABLE ROW LEVEL SECURITY;

-- ========== profiles 表权限 ==========

-- 所有人可以查看 profiles
CREATE POLICY "Profiles are viewable by everyone"
  ON public.profiles FOR SELECT
  USING (TRUE);

-- 用户只能插入自己的 profile（注册时）
CREATE POLICY "Users can insert their own profile"
  ON public.profiles FOR INSERT
  WITH CHECK (auth.uid() = id);

-- 用户只能更新自己的 profile
CREATE POLICY "Users can update their own profile"
  ON public.profiles FOR UPDATE
  USING (auth.uid() = id);

-- ========== poems 表权限 ==========

-- 所有人可以查看已发布的诗歌
CREATE POLICY "Published poems are viewable by everyone"
  ON public.poems FOR SELECT
  USING (is_published = TRUE OR author_id = auth.uid());

-- 用户可以创建自己的诗歌
CREATE POLICY "Users can create their own poems"
  ON public.poems FOR INSERT
  WITH CHECK (auth.uid() = author_id);

-- 用户只能更新自己的诗歌
CREATE POLICY "Users can update their own poems"
  ON public.poems FOR UPDATE
  USING (auth.uid() = author_id);

-- 用户只能删除自己的诗歌
CREATE POLICY "Users can delete their own poems"
  ON public.poems FOR DELETE
  USING (auth.uid() = author_id);

-- ========== likes 表权限 ==========

-- 所有人可以查看点赞
CREATE POLICY "Likes are viewable by everyone"
  ON public.likes FOR SELECT
  USING (TRUE);

-- 用户可以添加点赞
CREATE POLICY "Users can add likes"
  ON public.likes FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- 用户只能删除自己的点赞
CREATE POLICY "Users can remove their own likes"
  ON public.likes FOR DELETE
  USING (auth.uid() = user_id);

-- ========== favorites 表权限 ==========

-- 用户只能查看自己的收藏
CREATE POLICY "Users can view their own favorites"
  ON public.favorites FOR SELECT
  USING (auth.uid() = user_id);

-- 用户可以添加收藏
CREATE POLICY "Users can add favorites"
  ON public.favorites FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- 用户只能删除自己的收藏
CREATE POLICY "Users can remove their own favorites"
  ON public.favorites FOR DELETE
  USING (auth.uid() = user_id);

-- ========== comments 表权限 ==========

-- 所有人可以查看评论
CREATE POLICY "Comments are viewable by everyone"
  ON public.comments FOR SELECT
  USING (TRUE);

-- 用户可以创建评论
CREATE POLICY "Users can create comments"
  ON public.comments FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- 用户只能删除自己的评论
CREATE POLICY "Users can delete their own comments"
  ON public.comments FOR DELETE
  USING (auth.uid() = user_id);

-- ============================================
-- 视图：广场诗歌（包含作者信息）
-- ============================================

CREATE OR REPLACE VIEW public.square_poems AS
SELECT 
  p.id,
  p.title,
  p.content,
  p.created_at,
  p.like_count,
  p.view_count,
  p.tags,
  p.ai_comment,
  -- 作者信息
  prof.username AS author_username,
  prof.display_name AS author_display_name,
  prof.poet_title AS author_poet_title,
  -- 当前用户是否点赞
  EXISTS(
    SELECT 1 FROM public.likes l 
    WHERE l.poem_id = p.id AND l.user_id = auth.uid()
  ) AS is_liked_by_me
FROM public.poems p
JOIN public.profiles prof ON p.author_id = prof.id
WHERE p.is_published = TRUE
ORDER BY p.created_at DESC;

-- ============================================
-- 函数：获取热门诗歌（按点赞数排序）
-- ============================================

CREATE OR REPLACE FUNCTION public.get_popular_poems(limit_count INT DEFAULT 20)
RETURNS TABLE (
  id UUID,
  title TEXT,
  content TEXT,
  created_at TIMESTAMPTZ,
  like_count INT,
  view_count INT,
  tags TEXT[],
  author_username TEXT,
  author_display_name TEXT,
  author_poet_title TEXT,
  is_liked_by_me BOOLEAN
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    p.id,
    p.title,
    p.content,
    p.created_at,
    p.like_count,
    p.view_count,
    p.tags,
    prof.username,
    prof.display_name,
    prof.poet_title,
    EXISTS(
      SELECT 1 FROM public.likes l 
      WHERE l.poem_id = p.id AND l.user_id = auth.uid()
    ) AS is_liked
  FROM public.poems p
  JOIN public.profiles prof ON p.author_id = prof.id
  WHERE p.is_published = TRUE
  ORDER BY p.like_count DESC, p.created_at DESC
  LIMIT limit_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- 函数：更新诗人称号（根据诗歌数）
-- 与客户端 PoetTitle.swift 保持一致
-- ============================================

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

CREATE TRIGGER auto_update_poet_title BEFORE UPDATE ON public.profiles
  FOR EACH ROW 
  WHEN (OLD.total_poems IS DISTINCT FROM NEW.total_poems)
  EXECUTE FUNCTION update_poet_title();

-- ============================================
-- 初始化：创建匿名用户（用于测试）
-- ============================================

-- 注：实际使用时，用户需要通过 Supabase Auth 注册
-- 这里只是示例数据

COMMENT ON TABLE public.profiles IS '用户资料表';
COMMENT ON TABLE public.poems IS '诗歌表';
COMMENT ON TABLE public.likes IS '点赞表';
COMMENT ON TABLE public.favorites IS '收藏表';
COMMENT ON TABLE public.comments IS '评论表';

