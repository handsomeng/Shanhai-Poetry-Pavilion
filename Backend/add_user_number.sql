-- ============================================
-- 添加用户序号功能
-- 为 profiles 表添加注册序号
-- ============================================

-- 1. 添加 user_number 列（自增序列）
ALTER TABLE public.profiles 
ADD COLUMN IF NOT EXISTS user_number SERIAL;

-- 2. 为现有用户分配序号（按注册时间排序）
DO $$
DECLARE
    user_record RECORD;
    counter INTEGER := 1;
BEGIN
    -- 按 created_at 排序，为现有用户分配序号
    FOR user_record IN 
        SELECT id FROM public.profiles 
        WHERE user_number IS NULL 
        ORDER BY created_at ASC
    LOOP
        UPDATE public.profiles 
        SET user_number = counter 
        WHERE id = user_record.id;
        counter := counter + 1;
    END LOOP;
END $$;

-- 3. 创建触发器函数：为新用户自动分配序号
CREATE OR REPLACE FUNCTION assign_user_number()
RETURNS TRIGGER AS $$
BEGIN
    -- 如果 user_number 为空，自动分配下一个序号
    IF NEW.user_number IS NULL THEN
        NEW.user_number := COALESCE(
            (SELECT MAX(user_number) + 1 FROM public.profiles),
            1
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 4. 创建触发器（在插入前自动分配序号）
DROP TRIGGER IF EXISTS trigger_assign_user_number ON public.profiles;
CREATE TRIGGER trigger_assign_user_number
    BEFORE INSERT ON public.profiles
    FOR EACH ROW
    EXECUTE FUNCTION assign_user_number();

-- 5. 创建索引以提高查询性能
CREATE INDEX IF NOT EXISTS idx_profiles_user_number 
ON public.profiles(user_number);

-- 6. 验证结果
SELECT 
    id, 
    username, 
    user_number, 
    created_at 
FROM public.profiles 
ORDER BY user_number ASC 
LIMIT 10;

-- 完成！
-- 现在每个用户都有唯一的注册序号
-- 新注册用户会自动获得下一个序号

